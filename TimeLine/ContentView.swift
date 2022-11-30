//
//  ContentView.swift
//  Time Lines
//
//  Created by Mathieu Dutour on 02/04/2020.
//  Copyright © 2020 Mathieu Dutour. All rights reserved.
//

import SwiftUI
import TimeLineShared
import CoreLocation

enum AlertType {
  case noProducts
  case cantBuy
  case cantRestore
  case didRestore
  case upsell
}

struct MeRow: View {
  @Environment(\.editMode) var editMode

  var contacts: FetchedResults<Contact>

  private let currentTimeZone = TimeZone.autoupdatingCurrent
  private let roughLocation = TimeZone.autoupdatingCurrent.roughLocation

  var body: some View {
    Group {
      if editMode?.wrappedValue == EditMode.inactive || contacts.count == 0 {
        ContactRow(
          name: "Me",
          timezone: currentTimeZone,
          coordinate: roughLocation
        ).padding(.trailing, 15)
      }
    }
  }
}

struct BindedContactRow: View {
  @Environment(\.editMode) var editMode
  @EnvironmentObject var routeState: RouteState

  var contact: Contact
  @Binding var search: String
  @Binding var searchTokens: [Tag]

  var destination: some View {
    ContactDetails(contact: contact, onSelectTag: { tag, presentationMode in
      routeState.navigate(.list)
      presentationMode.dismiss()
      searchTokens = [tag]
      search = ""
    }, editView: {
      Button(action: {
        routeState.navigate(.editContact(contact: contact))
      }) {
        Text("Edit")
      }
      .padding(.init(top: 10, leading: 15, bottom: 10, trailing: 15))
      .background(Color(UIColor.systemBackground))
      .cornerRadius(5)
    })
  }

  var body: some View {
    NavigationLink(destination: destination, tag: contact, selection: $routeState.contactDetailed) {
      ContactRow(
        name: contact.name ?? "",
        timezone: contact.timeZone,
        coordinate: contact.location,
        startTime: contact.startTime,
        endTime: contact.endTime,
        hideLine: editMode?.wrappedValue == .active
      )
    }.onAppear(perform: {
      contact.refreshTimeZone()
    })
  }
}

struct ContentView: View {
  @Environment(\.managedObjectContext) var context
  @Environment(\.inAppPurchaseContext) var iapManager
  @EnvironmentObject var routeState: RouteState

  @FetchRequest(
      entity: Contact.entity(),
      sortDescriptors: [NSSortDescriptor(keyPath: \Contact.index, ascending: true)]
  ) var contacts: FetchedResults<Contact>

  @State private var showingSheet = false
  @State private var showingRestoreAlert = false
  @State private var showingAlert = false
  @State private var alertType: AlertType?
  @State private var errorMessage: String?
  @State private var search = ""
  @State private var searchTokens: [Tag] = []

  var addNewContact: some View {
    Button(action: {
      if (!iapManager.hasAlreadyPurchasedUnlimitedContacts && contacts.count >=
          iapManager.contactsLimit) {
          print("purchased: ", iapManager.hasAlreadyPurchasedUnlimitedContacts)
        showAlert(.upsell)
      } else {
        routeState.navigate(.editContact(contact: nil))
      }
    }) {
      HStack {
        Image(systemName: "plus").padding()
        Text("Add a new contact")
      }
    }.disabled(!iapManager.hasAlreadyPurchasedUnlimitedContacts && !iapManager.canBuy())
  }

  var body: some View {
    NavigationView {
      List {
        SearchBar(search: $search, tokens: $searchTokens)

        if search.count == 0 {
          addNewContact.foregroundColor(Color(UIColor.secondaryLabel))
        }

        MeRow(contacts: contacts)

        ForEach(contacts.filter { filterContact($0) }, id: \Contact.name) { (contact: Contact) in
          BindedContactRow(contact: contact, search: $search, searchTokens: $searchTokens)
        }
        .onDelete(perform: deleteContact)
        .onMove(perform: moveContact)
      }
      .resignKeyboardOnDragGesture()
      .navigationBarTitle(Text("Contacts"))
      .navigationBarItems(leading: contacts.count > 0 ? EditButton() : nil, trailing: Button(action: {
          showingSheet = true
      }) {
        Image(systemName: "person").padding()
      }
      .actionSheet(isPresented: $showingSheet) {
        ActionSheet(title: Text("Settings"), buttons: [
          .default(Text("Manage Tags"), action: {
            routeState.navigate(.tags)
          }),
          .default(Text("Send Feedback"), action: {
            UIApplication.shared.open(App.feedbackPage)
          }),
          .default(Text("Restore Purchases"), action: tryAgainRestore),
          .cancel()
        ])
      })
      .alert(isPresented: $showingAlert) {
        switch alertType {
        case .noProducts:
          return Alert(
            title: Text("Error while trying to get the In App Purchases"),
            message: Text(errorMessage ?? "Seems like there was an issue with the Apple's servers."),
            primaryButton: .cancel(Text("Cancel"), action: dismissAlert),
            secondaryButton: .default(Text("Try Again"), action: tryAgainBuyWithNoProduct)
          )
        case .cantBuy:
          return Alert(
            title: Text("Error while trying to purchase the product"),
            message: Text(errorMessage ?? "Seems like there was an issue with the Apple's servers."),
            primaryButton: .cancel(Text("Cancel"), action: dismissAlert),
            secondaryButton: .default(Text("Try Again"), action: tryAgainBuy)
          )
        case .cantRestore:
          return Alert(
            title: Text(errorMessage ?? "Error while trying to restore the purchases"),
            primaryButton: .cancel(Text("Cancel"), action: dismissAlert),
            secondaryButton: .default(Text("Try Again"), action: tryAgainRestore)
          )
        case .didRestore:
          return Alert(title: Text("Purchases restored successfully!"), dismissButton: .default(Text("OK")))
        case .upsell:
          return Alert(
            title: Text("You've reached the limit of the free Time Lines version"),
            message: Text("Unlock the full version to add an unlimited number of contacts."),
            primaryButton: .default(Text("Unlock Full Version"), action: tryAgainBuy),
            secondaryButton: .cancel(Text("Cancel"), action: dismissAlert)
          )
        case nil:
          return Alert(title: Text("Unknown Error"), dismissButton: .default(Text("OK")))
        }
      }

      // default view on iPad
      if contacts.count > 0 {
        ContactDetails(contact: contacts[0]) {
          Button(action: {
              routeState.navigate(.editContact(contact: contacts[0]))
          }) {
            Text("Edit")
          }
          .padding(.init(top: 10, leading: 15, bottom: 10, trailing: 15))
          .background(Color(UIColor.systemBackground))
          .cornerRadius(5)
        }
      } else {
        VStack {
          Text("Get started by adding a new contact")
          addNewContact.padding(.trailing, 20).foregroundColor(Color.accentColor).border(Color.accentColor)
        }
      }
    }.sheet(isPresented: $routeState.isShowingSheetFromList) {
      if routeState.isEditing {
        ContactEdition().environment(\.managedObjectContext, context).environmentObject(routeState)
      } else if routeState.isShowingTags {
        Tags().environment(\.managedObjectContext, context).environmentObject(routeState)
      }
    }

  }

  private func filterContact(_ contact: Contact) -> Bool {
    guard search.count == 0 || NSPredicate(format: "name contains[c] %@", argumentArray: [search]).evaluate(with: contact) || contact.tags?.first(where: { tag in
      guard let tag = tag as? Tag else {
        return false
      }
      return tag.name?.lowercased().contains(search.lowercased()) ?? false
    }) != nil else {
      return false
    }

    if searchTokens.count == 0 {
      return true
    }

    return searchTokens.allSatisfy { token in
      contact.tags?.first(where: { tag in
        guard let tag = tag as? Tag else {
          return false
        }
        return tag.name?.lowercased() == token.name?.lowercased()
      }) != nil
    }

  }

  private func deleteContact(at indexSet: IndexSet) {
    for index in indexSet {
      CoreDataManager.shared.deleteContact(contacts[index])
    }
  }

  private func moveContact(from source: IndexSet, to destination: Int) {
    for index in source {
      CoreDataManager.shared.moveContact(from: index, to: destination)
    }
  }

  private func showAlert(_ type: AlertType, withMessage message: String? = nil) {
      alertType = type
      errorMessage = message
      showingAlert = true
  }

  private func dismissAlert() {
      showingAlert = false
      alertType = nil
      errorMessage = nil
  }

  private func tryAgainBuyWithNoProduct() {
    dismissAlert()
      iapManager.getProducts(withHandler: { result in
      switch result {
      case .success(_):
          tryAgainBuy()
        break
      case .failure(let error):
          showAlert(.noProducts, withMessage: error.localizedDescription)
        break
      }
    })
  }

  private func tryAgainBuy() {
    dismissAlert()
    DispatchQueue.main.async {
      if let unlimitedContactsProduct = iapManager.unlimitedContactsProduct {
          iapManager.buy(product: unlimitedContactsProduct) { result in
          switch result {
          case .success(_):
              routeState.navigate(.editContact(contact: nil))
            break
          case .failure(let error):
            if let customError = error as? IAPManager.IAPManagerError, customError == .paymentWasCancelled {
              // don't do anything if it's cancelled
              return
            }
              showAlert(.cantBuy, withMessage: error.localizedDescription)
          }
        }
      } else {
          showAlert(.noProducts)
      }
    }
  }

  private func tryAgainRestore() {
    dismissAlert()
    DispatchQueue.main.async {
        iapManager.restorePurchases() { res in
        switch res {
        case .success(_):
            showAlert(.didRestore)
          break
        case .failure(let error):
          print(error)
            showAlert(.cantRestore, withMessage: error.localizedDescription)
        }
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
