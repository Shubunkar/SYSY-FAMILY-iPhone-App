import SwiftUI
import PhotosUI

/// Format Mauritian rupee amounts without unnecessary trailing zeroes.
private func formatAmount(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.locale = Locale(identifier: "en_MU")
    formatter.minimumFractionDigits = 0
    formatter.maximumFractionDigits = 2
    return formatter.string(from: NSNumber(value: value)) ?? String(value)
}

private func formatAmount(_ value: Int) -> String {
    formatAmount(Double(value))
}
struct MainTabView: View {
    @EnvironmentObject var store: AppDataStore
    @AppStorage("SYSY_FAMILY_LANGUAGE") private var selectedLanguage = "bn"
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView(onQuickAction: { selectedTab = $0 })
                .tabItem { Label(selectedLanguage == "en" ? "Home" : "হোম", systemImage: "house.fill") }
                .tag(0)

            CustomersView()
                .tabItem { Label(selectedLanguage == "en" ? "Customers" : "কাস্টমার", systemImage: "person.2.fill") }
                .tag(1)

            CustomerMeasurementFlowView()
                .tabItem { Label(selectedLanguage == "en" ? "Work" : "কাজ", systemImage: "ruler.and.arrowtriangle.2.inward") }
                .tag(2)

            QuotesView()
                .tabItem { Label(selectedLanguage == "en" ? "Quotations" : "কোটেশন", systemImage: "doc.text.fill") }
                .tag(3)

            PaymentsView()
                .tabItem { Label(selectedLanguage == "en" ? "Accounts" : "হিসাব", systemImage: "creditcard.fill") }
                .tag(4)

            SettingsView()
                .tabItem { Label(selectedLanguage == "en" ? "More" : "আরও", systemImage: "ellipsis") }
                .tag(5)
        }
        .tint(.sysyGold)
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

struct DashboardView: View {
    @EnvironmentObject var store: AppDataStore
    let onQuickAction: (Int) -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    AppCard {
                        HStack(spacing: 14) {
                            ProfileAvatar(size: 76)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("SYSY FAMILY")
                                    .font(.title2.bold())
                                    .foregroundStyle(Color.sysyNavy)
                                Text("Aluminium Door & Window Solutions")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("আপনার ব্যবসার হিসাব এক জায়গায়")
                                    .font(.subheadline)
                            }
                            Spacer()
                        }
                    }

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        StatCard(title: "Customer", value: "\(store.data.customers.count)", icon: "person.2.fill")
                        StatCard(title: "Quotation", value: "\(store.data.quotations.count)", icon: "doc.text.fill")
                        StatCard(title: "Collection", value: "MUR \(formatAmount(store.totalCollected))", icon: "banknote")
                        StatCard(title: "পাওনা", value: "MUR \(formatAmount(store.totalDue))", icon: "exclamationmark.circle")
                    }

                    AppCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("ব্যবসার সারাংশ").font(.headline)
                            SummaryRow(title: "মোট Sales", value: store.totalSales)
                            SummaryRow(title: "এই মাসের Sales", value: store.monthlySales)
                            SummaryRow(title: "এই মাসের Collection", value: store.monthlyCollection)
                            SummaryRow(title: "মোট Collection", value: store.totalCollected)
                            SummaryRow(title: "মোট Due", value: store.totalDue, emphasized: true)
                        }
                    }

                    if !store.data.quotations.isEmpty {
                        AppCard {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("সাম্প্রতিক Quotation").font(.headline)
                                    Spacer()
                                    Text("শেষ 5টি").font(.caption).foregroundStyle(.secondary)
                                }
                                ForEach(store.data.quotations.sorted(by: { $0.createdAt > $1.createdAt }).prefix(5)) { quotation in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(quotation.number).font(.subheadline.bold())
                                            Text(quotation.customerName).font(.caption).foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        VStack(alignment: .trailing, spacing: 2) {
                                            Text("MUR \(formatAmount(quotation.grandTotal))").font(.subheadline.bold())
                                            Text(quotation.createdAt.formatted(date: .abbreviated, time: .omitted)).font(.caption2).foregroundStyle(.secondary)
                                        }
                                    }
                                    if quotation.id != store.data.quotations.sorted(by: { $0.createdAt > $1.createdAt }).prefix(5).last?.id { Divider() }
                                }
                            }
                        }
                    }

                    if !store.data.payments.isEmpty {
                        AppCard {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Recent Activity • Payments").font(.headline)
                                ForEach(store.data.payments.sorted(by: { $0.date > $1.date }).prefix(3)) { payment in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(payment.customerName).font(.subheadline.bold())
                                            Text(payment.date.formatted(date: .abbreviated, time: .omitted))
                                                .font(.caption2).foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        Text("MUR \(formatAmount(payment.amount))")
                                            .font(.subheadline.bold()).foregroundStyle(.green)
                                    }
                                    if payment.id != store.data.payments.sorted(by: { $0.date > $1.date }).prefix(3).last?.id { Divider() }
                                }
                            }
                        }
                    }

                    AppCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("দ্রুত কাজ").font(.headline)
                            QuickAction(title: "নতুন কাস্টমার", icon: "person.badge.plus") { onQuickAction(1) }
                            QuickAction(title: "নতুন Measurement", icon: "ruler") { onQuickAction(2) }
                            QuickAction(title: "নতুন Quotation", icon: "doc.badge.plus") { onQuickAction(3) }
                            QuickAction(title: "Payment যোগ করুন", icon: "plus.circle") { onQuickAction(4) }
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("হোম")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: GlobalSearchView()) {
                        Image(systemName: "magnifyingglass")
                    }
                    .accessibilityLabel("সব তথ্য খুঁজুন")
                }
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: icon)
                    .foregroundStyle(Color.sysyGold)
                Text(title).font(.caption).foregroundStyle(.secondary)
                Text(value).font(.title3.bold()).foregroundStyle(Color.sysyNavy)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct QuickAction: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .frame(width: 28)
                    .foregroundStyle(Color.sysyGold)
                Text(title)
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct CustomersView: View {
    @EnvironmentObject var store: AppDataStore
    @State private var showAdd = false
    @State private var searchText = ""
    @State private var pendingDeleteIDs: Set<UUID> = []
    @State private var showDeleteConfirmation = false

    private var filteredCustomers: [Customer] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return store.data.customers }
        return store.data.customers.filter {
            $0.name.localizedCaseInsensitiveContains(query) ||
            $0.phone.localizedCaseInsensitiveContains(query) ||
            $0.address.localizedCaseInsensitiveContains(query) ||
            $0.projectAddress.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if filteredCustomers.isEmpty {
                    ContentUnavailableView(
                        searchText.isEmpty ? "কোনো Customer নেই" : "Customer পাওয়া যায়নি",
                        systemImage: searchText.isEmpty ? "person.2" : "magnifyingglass",
                        description: Text(searchText.isEmpty ? "উপরের + বাটন দিয়ে নতুন Customer যোগ করুন।" : "নাম, ফোন বা ঠিকানা দিয়ে আবার খুঁজুন।")
                    )
                } else {
                    List {
                        ForEach(filteredCustomers) { customer in
                            NavigationLink(destination: CustomerAccountDetailsView(customer: customer)) {
                                HStack(spacing: 12) {
                                    Image(systemName: "person.circle.fill")
                                        .font(.system(size: 34))
                                        .foregroundStyle(Color.sysyGold)
                                    VStack(alignment: .leading) {
                                        Text(customer.name).font(.headline)
                                        Text(customer.phone).font(.subheadline)
                                        Text(customer.address).font(.caption).foregroundStyle(.secondary)
                                    }
                                }
                                .padding(.vertical, 5)
                            }
                        }
                        .onDelete { offsets in
                            pendingDeleteIDs = Set(offsets.map { filteredCustomers[$0].id })
                            showDeleteConfirmation = true
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "নাম / ফোন / ঠিকানা খুঁজুন")
            .navigationTitle("কাস্টমার")
            .toolbar {
                Button { showAdd = true } label: { Image(systemName: "plus") }
            }
            .sheet(isPresented: $showAdd) {
                AddCustomerView { customer in store.addCustomer(customer) }
            }
            .confirmationDialog(
                "Customer Delete",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete permanently", role: .destructive) {
                    let ids = pendingDeleteIDs
                    let removedNames = Set(store.data.customers.filter { ids.contains($0.id) }.map { $0.name.lowercased() })
                    store.data.customers.removeAll { ids.contains($0.id) }
                    store.data.quotations.removeAll { removedNames.contains($0.customerName.lowercased()) }
                    store.data.payments.removeAll { removedNames.contains($0.customerName.lowercased()) }
                    store.data.measurements.removeAll { removedNames.contains($0.customerName.lowercased()) }
                    pendingDeleteIDs.removeAll()
                }
                Button("বাতিল", role: .cancel) { pendingDeleteIDs.removeAll() }
            } message: {
                Text("Customer মুছে ফেললে তার quotation, payment ও measurement history-ও মুছে যাবে।")
            }
        }
    }
}

struct AddCustomerView: View {
    @EnvironmentObject var store: AppDataStore
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var phone = ""
    @State private var address = ""
    @State private var duplicateCustomer: Customer?
    var onSave: (Customer) -> Void

    private var normalizedName: String { name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
    private var normalizedPhone: String { phone.filter { $0.isNumber } }

    var body: some View {
        NavigationStack {
            Form {
                Section("কাস্টমার তথ্য") {
                    TextField("নাম", text: $name)
                    TextField("ফোন", text: $phone)
                        .keyboardType(.phonePad)
                    TextField("ঠিকানা", text: $address)
                }
                if let duplicateCustomer {
                    Section("সম্ভাব্য Duplicate") {
                        Label("\(duplicateCustomer.name) • \(duplicateCustomer.phone)", systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                        Text("একই customer আগে থেকেই আছে। নতুন customer তৈরি করার আগে তথ্যটি যাচাই করুন।")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("নতুন কাস্টমার")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("বাতিল") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("সেভ") { saveCustomer() }
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func saveCustomer() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        let matches = store.data.customers.filter {
            let sameName = $0.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == normalizedName
            let existingPhone = $0.phone.filter { $0.isNumber }
            let samePhone = !normalizedPhone.isEmpty && normalizedPhone == existingPhone
            return sameName || samePhone
        }
        if let first = matches.first {
            duplicateCustomer = first
            return
        }
        onSave(Customer(name: trimmedName, phone: phone, address: address))
        dismiss()
    }
}



struct CustomerMeasurementFlowView: View {
    @EnvironmentObject var store: AppDataStore
    @State private var selectedCustomer: Customer?
    @State private var title = "Aluminium Window"
    @State private var width = ""
    @State private var height = ""
    @State private var quantity = "1"
    @State private var rate = ""
    @State private var selectedRate: RateItem?
    @State private var measurements: [CustomerMeasurement] = []
    @State private var editingMeasurement: CustomerMeasurement?
    @State private var showQuotation = false
    @State private var showMeterCalculator = false

    private var sqft: Double {
        (Double(width) ?? 0) * (Double(height) ?? 0) * Double(Int(quantity) ?? 1)
    }

    private var amount: Double {
        sqft * (Double(rate) ?? 0)
    }

    private var customerMeasurements: [CustomerMeasurement] {
        guard let selectedCustomer else { return [] }
        return store.data.measurements.filter { $0.customerName == selectedCustomer.name }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("১. Customer নির্বাচন") {
                    Picker("Customer", selection: $selectedCustomer) {
                        Text("Customer নির্বাচন করুন").tag(Optional<Customer>.none)
                        ForEach(store.data.customers) { customer in
                            Text(customer.name).tag(Optional(customer))
                        }
                    }
                }

                Section("২. Measurement") {
                    TextField("Door / Window নাম", text: $title)
                    TextField("Width (ft)", text: $width)
                        .keyboardType(.decimalPad)
                    TextField("Height (ft)", text: $height)
                        .keyboardType(.decimalPad)
                    TextField("Quantity", text: $quantity)
                        .keyboardType(.numberPad)
                    Picker("Saved Rate", selection: $selectedRate) {
                        Text("নিজে Rate লিখুন").tag(Optional<RateItem>.none)
                        ForEach(store.data.rates) { item in
                            Text("\(item.name) — MUR \(formatAmount(item.rate))")
                                .tag(Optional(item))
                        }
                    }
                    .onChange(of: selectedRate) { _, newValue in
                        if let newValue {
                            rate = String(format: "%.2f", newValue.rate)
                        }
                    }

                    TextField("Rate / Sqft", text: $rate)
                        .keyboardType(.decimalPad)

                    HStack {
                        Text("Total Sqft")
                        Spacer()
                        Text("\(sqft, specifier: "%.2f")")
                            .bold()
                    }

                    HStack {
                        Text("Amount")
                        Spacer()
                        Text("MUR \(formatAmount(amount))")
                            .bold()
                            .foregroundStyle(Color.sysyGold)
                    }

                    Button {
                        showMeterCalculator = true
                    } label: {
                        Label("Meter হিসাব খুলুন", systemImage: "ruler")
                    }

                    Button("Measurement Save করুন") {
                        guard let customer = selectedCustomer,
                              sqft > 0, amount > 0 else { return }

                        let item = CustomerMeasurement(
                            customerName: customer.name,
                            title: title,
                            width: Double(width) ?? 0,
                            height: Double(height) ?? 0,
                            quantity: Int(quantity) ?? 1,
                            rate: Double(rate) ?? 0
                        )
                        store.addMeasurement(item)

                        width = ""
                        height = ""
                        quantity = "1"
                    }
                    .disabled(selectedCustomer == nil || sqft <= 0 || amount <= 0)
                }

                Section("৩. এই Customer-এর Measurements") {
                    if customerMeasurements.isEmpty {
                        Text("এখনও কোনো measurement নেই")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(customerMeasurements) { item in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(item.title).font(.headline)
                                Text("\(item.width, specifier: "%.1f") × \(item.height, specifier: "%.1f") × \(item.quantity) = \(item.sqft, specifier: "%.2f") Sqft")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("MUR \(formatAmount(item.amount))")
                                    .bold()
                                    .foregroundStyle(Color.sysyGold)
                                HStack {
                                    Button {
                                        editingMeasurement = item
                                    } label: {
                                        Label("Edit মাপ", systemImage: "pencil")
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(.blue)
                                    Spacer()
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }

                Section("৪. Quotation") {
                    Button {
                        showQuotation = true
                    } label: {
                        Label("এই Measurement দিয়ে Quotation বানান", systemImage: "doc.badge.plus")
                    }
                    .disabled(selectedCustomer == nil || customerMeasurements.isEmpty)
                }
            }
            .navigationTitle("Customer → Measurement")
            .sheet(isPresented: $showMeterCalculator) {
                MeterCalculatorView(customer: selectedCustomer)
                    .environmentObject(store)
            }
            .sheet(isPresented: $showQuotation) {
                NavigationStack {
                    if let customer = selectedCustomer {
                        FlowQuotationView(
                            customer: customer,
                            measurements: customerMeasurements
                        )
                        .environmentObject(store)
                    }
                }
            }
            .sheet(item: $editingMeasurement) { item in
                EditMeasurementView(measurement: item)
                    .environmentObject(store)
            }
        }
    }
}

struct FlowQuotationView: View {
    @EnvironmentObject var store: AppDataStore
    @Environment(\.dismiss) private var dismiss
    let customer: Customer
    let measurements: [CustomerMeasurement]
    @State private var discount = "0"
    @State private var advance = "0"
    @State private var saved = false

    private var subtotal: Double {
        measurements.reduce(0) { $0 + $1.amount }
    }
    private var discountValue: Double { Double(discount) ?? 0 }
    private var advanceValue: Double { Double(advance) ?? 0 }
    private var total: Double { max(0, subtotal - discountValue) }
    private var balance: Double { max(0, total - advanceValue) }

    var body: some View {
        Form {
            Section("Customer") {
                Text(customer.name).font(.headline)
                Text(customer.phone)
            }

            Section("Measurement Items") {
                ForEach(measurements) { item in
                    HStack {
                        Text(item.title)
                        Spacer()
                        Text("MUR \(formatAmount(item.amount))")
                    }
                }
            }

            Section("Payment") {
                TextField("Discount", text: $discount)
                    .keyboardType(.decimalPad)
                TextField("Advance", text: $advance)
                    .keyboardType(.decimalPad)

                SummaryRow(title: "Subtotal", value: subtotal)
                SummaryRow(title: "Grand Total", value: total, emphasized: true)
                SummaryRow(title: "Balance Due", value: balance, emphasized: true)
            }

            Button("Quotation Save করুন") {
                let quotation = BusinessQuotation(
                    number: "QT-\(Int(Date().timeIntervalSince1970))",
                    customerName: customer.name,
                    phone: customer.phone,
                    projectAddress: customer.projectAddress,
                    siteNote: customer.siteNote,
                    lines: measurements.map {
                        QuotationLine(
                            title: $0.title,
                            description: "\(String(format: "%.1f", $0.width)) × \(String(format: "%.1f", $0.height)) × \($0.quantity) = \(String(format: "%.2f", $0.sqft)) Sqft",
                            amount: $0.amount
                        )
                    },
                    discount: discountValue,
                    advance: advanceValue,
                    advanceDate: advanceValue > 0 ? Date() : nil
                )
                store.addQuotation(quotation)
                saved = true
            }
            .disabled(saved)

            if saved {
                Label("Quotation সফলভাবে save হয়েছে", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
        }
        .navigationTitle("Quotation")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("বন্ধ") { dismiss() }
            }
        }
    }
}

struct MeterCalculatorView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var store: AppDataStore
    let customer: Customer?
    @State private var title = "Aluminium Window"
    @State private var width = ""
    @State private var height = ""
    @State private var quantity = "1"
    @State private var rate = ""

    private var squareMeter: Double {
        (Double(width) ?? 0) * (Double(height) ?? 0) * Double(Int(quantity) ?? 1)
    }

    private var squareFeet: Double {
        squareMeter * 10.7639104167
    }

    private var amount: Double {
        squareMeter * (Double(rate) ?? 0)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Meter Measurement") {
                    TextField("Door / Window নাম", text: $title)
                    TextField("Width (meter)", text: $width)
                        .keyboardType(.decimalPad)
                    TextField("Height (meter)", text: $height)
                        .keyboardType(.decimalPad)
                    TextField("Quantity", text: $quantity)
                        .keyboardType(.numberPad)
                    TextField("Rate / Sq Meter", text: $rate)
                        .keyboardType(.decimalPad)
                }

                Section("Automatic হিসাব") {
                    HStack {
                        Text("Square Meter")
                        Spacer()
                        Text("\(squareMeter, specifier: "%.2f") m²")
                            .bold()
                    }
                    HStack {
                        Text("Equivalent Sqft")
                        Spacer()
                        Text("\(squareFeet, specifier: "%.2f") Sqft")
                            .bold()
                    }
                    HStack {
                        Text("Total Amount")
                        Spacer()
                        Text("MUR \(formatAmount(amount))")
                            .bold()
                            .foregroundStyle(Color.sysyGold)
                    }
                }

                Section {
                    Button {
                        guard let customer,
                              let savedWidth = Double(width),
                              let savedHeight = Double(height),
                              let savedQuantity = Int(quantity),
                              let savedRate = Double(rate),
                              !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                              savedWidth > 0, savedHeight > 0, savedQuantity > 0, savedRate > 0 else {
                            return
                        }

                        // Save using the existing sqft-based model while preserving the entered M² total.
                        let widthFeet = savedWidth * 3.280839895
                        let heightFeet = savedHeight * 3.280839895
                        let equivalentRatePerSqft = savedRate / 10.7639104167
                        store.addMeasurement(
                            CustomerMeasurement(
                                customerName: customer.name,
                                title: "\(title.trimmingCharacters(in: .whitespacesAndNewlines)) (Meter)",
                                width: widthFeet,
                                height: heightFeet,
                                quantity: savedQuantity,
                                rate: equivalentRatePerSqft
                            )
                        )
                        dismiss()
                    } label: {
                        Label("হিসাব Save করুন", systemImage: "square.and.arrow.down")
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(customer == nil || (Double(width) ?? 0) <= 0 || (Double(height) ?? 0) <= 0 || (Double(rate) ?? 0) <= 0 || (Int(quantity) ?? 0) <= 0)

                    if customer == nil {
                        Text("এই হিসাব সেভ করতে আগে Work স্ক্রিনে Customer নির্বাচন করুন।")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    Text("এখানে Meter ও Square Meter-এর হিসাব হবে। Running Meter এই অ্যাপে রাখা হয়নি।")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Meter হিসাব")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("বন্ধ") { dismiss() }
                }
            }
        }
    }
}


struct MeasurementView: View {
    @EnvironmentObject var store: AppDataStore
    @State private var customerName = ""
    @State private var title = "Aluminium Window"
    @State private var width = ""
    @State private var height = ""
    @State private var quantity = "1"
    @State private var rate = ""
    @State private var selectedRate: RateItem?
    @State private var saveMessage = ""
    @State private var editingMeasurement: CustomerMeasurement?
    @State private var measurementToDelete: CustomerMeasurement?

    private var sqft: Double {
        guard let w = Double(width), let h = Double(height), let q = Int(quantity) else { return 0 }
        return w * h * Double(q)
    }

    private var total: Double {
        guard let r = Double(rate) else { return 0 }
        return sqft * r
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("কাজের তথ্য") {
                    TextField("কাস্টমারের নাম", text: $customerName)
                    TextField("Door / Window নাম", text: $title)
                    TextField("Width (ft)", text: $width)
                        .keyboardType(.decimalPad)
                    TextField("Height (ft)", text: $height)
                        .keyboardType(.decimalPad)
                    TextField("Quantity", text: $quantity)
                        .keyboardType(.numberPad)
                    Picker("Saved Rate", selection: $selectedRate) {
                        Text("নিজে Rate লিখুন").tag(Optional<RateItem>.none)
                        ForEach(store.data.rates) { item in
                            Text("\(item.name) — MUR \(formatAmount(item.rate))")
                                .tag(Optional(item))
                        }
                    }
                    .onChange(of: selectedRate) { _, newValue in
                        if let newValue {
                            rate = String(format: "%.2f", newValue.rate)
                        }
                    }

                    TextField("Rate / Sqft", text: $rate)
                        .keyboardType(.decimalPad)
                }

                Section("Automatic হিসাব") {
                    HStack {
                        Text("Total Sqft")
                        Spacer()
                        Text("\(sqft, specifier: "%.2f") Sqft")
                            .bold()
                            .foregroundStyle(Color.sysyGold)
                    }
                    HStack {
                        Text("Total Amount")
                        Spacer()
                        Text("MUR \(formatAmount(total))")
                            .bold()
                            .foregroundStyle(Color.sysyNavy)
                    }
                }

                Button {
                    let name = customerName.trimmingCharacters(in: .whitespacesAndNewlines)
                    let itemTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !name.isEmpty, !itemTitle.isEmpty, sqft > 0, total > 0,
                          let savedWidth = Double(width),
                          let savedHeight = Double(height),
                          let savedRate = Double(rate),
                          let savedQuantity = Int(quantity), savedQuantity > 0 else {
                        saveMessage = "কাস্টমারের নাম, সঠিক মাপ, Quantity ও Rate দিন।"
                        return
                    }
                    store.addMeasurement(
                        CustomerMeasurement(
                            customerName: name,
                            title: itemTitle,
                            width: savedWidth,
                            height: savedHeight,
                            quantity: savedQuantity,
                            rate: savedRate
                        )
                    )
                    saveMessage = "হিসাব সেভ হয়েছে।"
                    width = ""
                    height = ""
                    quantity = "1"
                    rate = ""
                } label: {
                    Label("Measurement Save করুন", systemImage: "square.and.arrow.down")
                        .frame(maxWidth: .infinity)
                }

                if !saveMessage.isEmpty {
                    Section {
                        Text(saveMessage)
                            .font(.footnote)
                            .foregroundStyle(saveMessage == "হিসাব সেভ হয়েছে।" ? .green : .red)
                    }
                }

                if !store.data.measurements.isEmpty {
                    Section("সেভ করা হিসাব") {
                        ForEach(store.data.measurements.reversed()) { item in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.customerName).font(.headline)
                                Text(item.title)
                                Text("\(item.width, specifier: "%.1f") × \(item.height, specifier: "%.1f") × \(item.quantity) = \(item.sqft, specifier: "%.2f") Sqft")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("MUR \(formatAmount(item.amount))")
                                    .bold()
                                    .foregroundStyle(Color.sysyGold)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button {
                                    editingMeasurement = item
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.blue)
                                Button(role: .destructive) {
                                    measurementToDelete = item
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Measurement")
            .sheet(item: $editingMeasurement) { item in
                EditMeasurementView(measurement: item)
                    .environmentObject(store)
            }
            .alert("Measurement Delete", isPresented: Binding(
                get: { measurementToDelete != nil },
                set: { if !$0 { measurementToDelete = nil } }
            )) {
                Button("Cancel", role: .cancel) { measurementToDelete = nil }
                Button("Delete", role: .destructive) {
                    if let item = measurementToDelete {
                        var updated = store.data
                        updated.measurements.removeAll { $0.id == item.id }
                        store.data = updated
                    }
                    measurementToDelete = nil
                }
            } message: {
                Text("এই measurement মুছে ফেললে আর ফেরত পাওয়া যাবে না।")
            }
        }
    }
}

struct EditMeasurementView: View {
    @EnvironmentObject var store: AppDataStore
    @Environment(\.dismiss) private var dismiss
    let measurement: CustomerMeasurement
    @State private var customerName: String
    @State private var title: String
    @State private var width: String
    @State private var height: String
    @State private var quantity: String
    @State private var rate: String
    @State private var errorMessage = ""

    init(measurement: CustomerMeasurement) {
        self.measurement = measurement
        _customerName = State(initialValue: measurement.customerName)
        _title = State(initialValue: measurement.title)
        _width = State(initialValue: String(measurement.width))
        _height = State(initialValue: String(measurement.height))
        _quantity = State(initialValue: String(measurement.quantity))
        _rate = State(initialValue: String(measurement.rate))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Measurement Edit") {
                    TextField("Customer name", text: $customerName)
                    TextField("Door / Window name", text: $title)
                    TextField("Width (ft)", text: $width).keyboardType(.decimalPad)
                    TextField("Height (ft)", text: $height).keyboardType(.decimalPad)
                    TextField("Quantity", text: $quantity).keyboardType(.numberPad)
                    TextField("Rate / Sqft (MUR)", text: $rate).keyboardType(.decimalPad)
                }
                if !errorMessage.isEmpty {
                    Text(errorMessage).foregroundStyle(.red).font(.footnote)
                }
                Section {
                    Button("Save Changes") { saveChanges() }
                        .disabled(customerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                                  title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                                  (Double(width) ?? 0) <= 0 || (Double(height) ?? 0) <= 0 ||
                                  (Int(quantity) ?? 0) <= 0 || (Double(rate) ?? -1) < 0)
                }
            }
            .navigationTitle("Measurement Edit")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Back") { dismiss() }
                }
            }
        }
    }

    private func saveChanges() {
        guard let savedWidth = Double(width), let savedHeight = Double(height),
              let savedQuantity = Int(quantity), let savedRate = Double(rate),
              savedWidth > 0, savedHeight > 0, savedQuantity > 0, savedRate >= 0 else {
            errorMessage = "সঠিক Width, Height, Quantity ও Rate দিন।"
            return
        }
        let name = customerName.trimmingCharacters(in: .whitespacesAndNewlines)
        let itemTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty, !itemTitle.isEmpty else {
            errorMessage = "Customer ও Measurement-এর নাম লিখুন।"
            return
        }
        var updated = store.data
        if let index = updated.measurements.firstIndex(where: { $0.id == measurement.id }) {
            updated.measurements[index] = CustomerMeasurement(
                id: measurement.id,
                customerName: name,
                title: itemTitle,
                width: savedWidth,
                height: savedHeight,
                quantity: savedQuantity,
                rate: savedRate
            )
            store.data = updated
            dismiss()
        }
    }
}


struct QuotationBuilderView: View {
    @EnvironmentObject var store: AppDataStore
    @State private var customerName = ""
    @State private var phone = ""
    @State private var projectAddress = ""
    @State private var siteNote = ""
    @State private var status: QuotationStatus = .draft
    @State private var itemName = "Aluminium Door / Window"
    @State private var amountText = ""
    @State private var discountText = "0"
    @State private var advanceText = "0"
    @State private var lines: [QuotationLine] = []

    private var subtotal: Double { lines.reduce(0) { $0 + $1.amount } }
    private var discount: Double { Double(discountText) ?? 0 }
    private var advance: Double { max(0, Double(advanceText) ?? 0) }
    private var grandTotal: Double { max(0, subtotal - discount) }
    private var balance: Double { max(0, grandTotal - min(advance, grandTotal)) }
    private var isCustomerValid: Bool { !customerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    private var isDiscountValid: Bool { discount >= 0 && discount <= subtotal }
    private var isAdvanceValid: Bool { advance >= 0 && advance <= grandTotal }

    var body: some View {
        Form {
            Section("Customer") {
                TextField("Customer Name", text: $customerName)
                TextField("Phone", text: $phone)
                    .keyboardType(.phonePad)
                TextField("Project / Site Address", text: $projectAddress, axis: .vertical)
                    .lineLimit(2...4)
                TextField("Site Note", text: $siteNote, axis: .vertical)
                    .lineLimit(2...4)
                Picker("Quotation Status", selection: $status) {
                    ForEach(QuotationStatus.allCases) { item in
                        Text(item.banglaTitle).tag(item)
                    }
                }
            }

            Section("Measurement / Item") {
                TextField("Item name", text: $itemName)
                TextField("Amount", text: $amountText)
                    .keyboardType(.decimalPad)

                Button("Item যোগ করুন") {
                    guard let amount = Double(amountText), amount > 0 else { return }
                    lines.append(QuotationLine(
                        title: itemName,
                        description: "Saved measurement / business item",
                        amount: amount
                    ))
                    amountText = ""
                }
            }

            if !lines.isEmpty {
                Section("Items") {
                    ForEach(lines) { line in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(line.title).font(.headline)
                                Text(line.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text("MUR \(formatAmount(line.amount))")
                        }
                    }
                    .onDelete { lines.remove(atOffsets: $0) }
                }
            }

            Section("Payment") {
                HStack {
                    Text("Subtotal")
                    Spacer()
                    Text("MUR \(formatAmount(subtotal))")
                }
                TextField("Discount", text: $discountText)
                    .keyboardType(.decimalPad)
                if discount > subtotal {
                    Text("Discount মোট amount-এর চেয়ে বেশি হতে পারবে না")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
                TextField("Advance", text: $advanceText)
                    .keyboardType(.decimalPad)
                if advance > grandTotal {
                    Text("Advance Grand Total-এর চেয়ে বেশি হতে পারবে না")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
                HStack {
                    Text("Grand Total").bold()
                    Spacer()
                    Text("MUR \(formatAmount(grandTotal))")
                        .bold()
                        .foregroundStyle(Color.sysyGold)
                }
                HStack {
                    Text("বাকি").bold()
                    Spacer()
                    Text("MUR \(formatAmount(balance))")
                        .bold()
                        .foregroundStyle(.red)
                }
            }

            Section {
                NavigationLink("Quotation Preview") {
                    let quotation = BusinessQuotation(
                        number: store.nextQuotationNumber(),
                        customerName: customerName.trimmingCharacters(in: .whitespacesAndNewlines),
                        phone: phone.trimmingCharacters(in: .whitespacesAndNewlines),
                        projectAddress: projectAddress.trimmingCharacters(in: .whitespacesAndNewlines),
                        siteNote: siteNote.trimmingCharacters(in: .whitespacesAndNewlines),
                        status: status,
                        lines: lines,
                        discount: discount,
                        advance: advance
                    )
                    QuotationPreviewView(quotation: quotation)
                        .onAppear {
                            if !store.data.quotations.contains(where: { $0.number == quotation.number }) {
                                store.addQuotation(quotation)
                            }
                        }
                }
                .disabled(!isCustomerValid || lines.isEmpty || !isDiscountValid || !isAdvanceValid)
            }
        }
        .navigationTitle("নতুন Quotation")
    }
}


import UIKit
import PhotosUI
import UniformTypeIdentifiers

struct PDFShareSheet: UIViewControllerRepresentable {
    let quotation: BusinessQuotation

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let pdfData = makePDF()
        let filename = "SYSY-FAMILY-Quotation-\(quotation.number).pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        try? pdfData.write(to: url, options: .atomic)

        let controller = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}

    private func makePDF() -> Data {
        let pageSize = CGSize(width: 595, height: 842)
        let margin: CGFloat = 40
        let contentWidth = pageSize.width - (margin * 2)
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize))

        return renderer.pdfData { context in
            var y: CGFloat = margin

            func beginPage() {
                context.beginPage()
                y = margin
            }

            func drawText(
                _ value: String,
                font: UIFont,
                color: UIColor = .label,
                spacingAfter: CGFloat = 7
            ) {
                let paragraph = NSMutableParagraphStyle()
                paragraph.lineBreakMode = .byWordWrapping
                paragraph.alignment = .left

                let attributes: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: color,
                    .paragraphStyle: paragraph
                ]

                let rect = (value as NSString).boundingRect(
                    with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: attributes,
                    context: nil
                )

                let requiredHeight = ceil(rect.height)
                if y + requiredHeight > pageSize.height - margin {
                    beginPage()
                }

                (value as NSString).draw(
                    in: CGRect(x: margin, y: y, width: contentWidth, height: requiredHeight),
                    withAttributes: attributes
                )
                y += requiredHeight + spacingAfter
            }

            func drawRule() {
                let path = UIBezierPath()
                path.move(to: CGPoint(x: margin, y: y))
                path.addLine(to: CGPoint(x: pageSize.width - margin, y: y))
                UIColor.separator.setStroke()
                path.lineWidth = 0.7
                path.stroke()
                y += 12
            }

            beginPage()

            // Branded SYSY mark in the PDF header.
            let logoLeft = CGRect(x: pageSize.width - margin - 42, y: y + 1, width: 18, height: 24)
            let logoRight = CGRect(x: pageSize.width - margin - 21, y: y + 1, width: 18, height: 24)
            UIColor(red: 0.82, green: 0.60, blue: 0.18, alpha: 1).setStroke()
            UIBezierPath(roundedRect: logoLeft, cornerRadius: 3).stroke()
            UIColor(red: 0.02, green: 0.08, blue: 0.18, alpha: 1).setStroke()
            UIBezierPath(roundedRect: logoRight, cornerRadius: 3).stroke()

            drawText(
                "SYSY FAMILY",
                font: .boldSystemFont(ofSize: 26),
                color: UIColor(red: 0.02, green: 0.08, blue: 0.18, alpha: 1),
                spacingAfter: 3
            )
            drawText("Aluminium Door & Window Solutions", font: .systemFont(ofSize: 12), spacingAfter: 3)
            drawText("Mobile: +230 5890 9358", font: .systemFont(ofSize: 11), color: UIColor.darkGray, spacingAfter: 12)
            drawRule()

            drawText("QUOTATION", font: .boldSystemFont(ofSize: 20), spacingAfter: 5)
            drawText("Quotation No: \(quotation.number)", font: .systemFont(ofSize: 12), spacingAfter: 3)
            drawText("Status: \(quotation.status.rawValue)", font: .systemFont(ofSize: 11), spacingAfter: 3)
            drawText(
                "Date: \(quotation.createdAt.formatted(date: .abbreviated, time: .omitted))",
                font: .systemFont(ofSize: 12),
                spacingAfter: 10
            )

            drawText("CUSTOMER DETAILS", font: .boldSystemFont(ofSize: 11), color: UIColor.systemBlue, spacingAfter: 4)
            drawText("Name: \(quotation.customerName)", font: .systemFont(ofSize: 12), spacingAfter: 3)
            if !quotation.phone.isEmpty {
                drawText("Phone: \(quotation.phone)", font: .systemFont(ofSize: 12), spacingAfter: 3)
            }

            if !quotation.projectAddress.isEmpty || !quotation.siteNote.isEmpty {
                y += 6
                drawText("PROJECT / SITE", font: .boldSystemFont(ofSize: 11), color: UIColor.systemBlue, spacingAfter: 4)
                if !quotation.projectAddress.isEmpty {
                    drawText("Address: \(quotation.projectAddress)", font: .systemFont(ofSize: 11), spacingAfter: 3)
                }
                if !quotation.siteNote.isEmpty {
                    drawText("Note: \(quotation.siteNote)", font: .systemFont(ofSize: 11), spacingAfter: 6)
                }
            }

            y += 5
            drawRule()
            drawText("WORK DETAILS", font: .boldSystemFont(ofSize: 11), color: UIColor.systemBlue, spacingAfter: 6)

            for line in quotation.lines {
                drawText(line.title, font: .boldSystemFont(ofSize: 12), spacingAfter: 2)
                drawText(line.description, font: .systemFont(ofSize: 10), color: .secondaryLabel, spacingAfter: 2)
                drawText("Amount: MUR \(formatAmount(line.amount))", font: .systemFont(ofSize: 12), spacingAfter: 7)
            }

            y += 5
            drawRule()
            drawText("Subtotal: MUR \(formatAmount(quotation.subtotal))", font: .systemFont(ofSize: 12), spacingAfter: 3)
            drawText("Discount: MUR \(formatAmount(quotation.discount))", font: .systemFont(ofSize: 12), spacingAfter: 3)
            drawText("Grand Total: MUR \(formatAmount(quotation.grandTotal))", font: .boldSystemFont(ofSize: 14), spacingAfter: 3)
            drawText("Advance: MUR \(formatAmount(quotation.advance))", font: .systemFont(ofSize: 12), spacingAfter: 3)
            drawText("Balance Due: MUR \(formatAmount(quotation.balance))", font: .boldSystemFont(ofSize: 14), spacingAfter: 10)

            drawText("TERMS & CONDITIONS", font: .boldSystemFont(ofSize: 11), color: UIColor.systemBlue, spacingAfter: 4)
            drawText("• Final measurement will be confirmed before production.", font: .systemFont(ofSize: 10), spacingAfter: 3)
            drawText("• Quotation amount is based on the listed measurements and rates.", font: .systemFont(ofSize: 10), spacingAfter: 3)
            drawText("• Any additional work or material will be charged separately.", font: .systemFont(ofSize: 10), spacingAfter: 12)

            if y + 70 > pageSize.height - margin {
                beginPage()
            }

            drawText("Customer Signature", font: .systemFont(ofSize: 10), spacingAfter: 2)
            let signatureY = y
            let half = (contentWidth - 30) / 2
            let path = UIBezierPath()
            path.move(to: CGPoint(x: margin, y: signatureY + 18))
            path.addLine(to: CGPoint(x: margin + half, y: signatureY + 18))
            path.move(to: CGPoint(x: margin + half + 30, y: signatureY + 18))
            path.addLine(to: CGPoint(x: pageSize.width - margin, y: signatureY + 18))
            UIColor.secondaryLabel.setStroke()
            path.lineWidth = 0.7
            path.stroke()
            y += 32
            drawText("Customer / Authorized Approval", font: .systemFont(ofSize: 9), color: .secondaryLabel, spacingAfter: 4)

            drawText("Thank you for your business.", font: .systemFont(ofSize: 10), color: .secondaryLabel, spacingAfter: 0)
        }
    }
}

struct QuotationPreviewView: View {
    let quotation: BusinessQuotation
    @State private var showShare = false
    @EnvironmentObject var store: AppDataStore

    private var customer: Customer? {
        store.data.customers.first {
            $0.name == quotation.customerName && (quotation.phone.isEmpty || $0.phone == quotation.phone)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Company header
                HStack(alignment: .top, spacing: 14) {
                    SYSYLogoView()
                        .frame(width: 74, height: 74)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 4) {
                        Text("SYSY FAMILY")
                            .font(.title2.bold())
                            .foregroundStyle(Color.sysyNavy)
                        Text("Aluminium Door & Window Solutions")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("Professional Quotation")
                            .font(.caption2)
                            .foregroundStyle(Color.sysyGold)
                    }

                    Spacer()
                }
                .padding(.bottom, 14)

                Divider()

                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("QUOTATION")
                            .font(.title.bold())
                        Text("No: \(quotation.number)")
                            .font(.caption)
                        Text(quotation.status.banglaTitle)
                            .font(.caption2.bold())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.sysyNavy.opacity(0.10))
                            .clipShape(Capsule())
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 5) {
                        Text("Date")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(quotation.createdAt.formatted(date: .abbreviated, time: .omitted))
                            .font(.subheadline.bold())
                    }
                }
                .padding(.vertical, 14)

                // Customer information
                VStack(alignment: .leading, spacing: 6) {
                    Text("CUSTOMER DETAILS")
                        .font(.caption.bold())
                        .foregroundStyle(Color.sysyGold)
                    Text(quotation.customerName)
                        .font(.headline)
                    if !quotation.phone.isEmpty {
                        Text("Phone: \(quotation.phone)")
                            .font(.subheadline)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 6) {
                    Text("PROJECT / SITE")
                        .font(.caption.bold())
                        .foregroundStyle(Color.sysyGold)
                    if !quotation.projectAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text(quotation.projectAddress)
                            .font(.subheadline)
                    } else {
                        Text("No project/site address saved.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    if !quotation.siteNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text(quotation.siteNote)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.top, 14)

                Text("WORK DETAILS")
                    .font(.caption.bold())
                    .foregroundStyle(Color.sysyGold)
                    .padding(.top, 18)
                    .padding(.bottom, 8)

                VStack(spacing: 0) {
                    HStack {
                        Text("Description").bold()
                        Spacer()
                        Text("Amount").bold()
                    }
                    .font(.caption)
                    .padding(10)
                    .background(Color.sysyNavy.opacity(0.08))

                    ForEach(quotation.lines) { line in
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(line.title).font(.subheadline.bold())
                                Text(line.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text("MUR \(formatAmount(line.amount))")
                                .font(.subheadline.bold())
                        }
                        .padding(10)
                        Divider()
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.secondary.opacity(0.2))
                )

                VStack(alignment: .trailing, spacing: 7) {
                    SummaryRow(title: "Subtotal", value: quotation.subtotal)
                    SummaryRow(title: "Discount", value: quotation.discount)
                    SummaryRow(title: "Grand Total", value: quotation.grandTotal, emphasized: true)
                    SummaryRow(title: "Advance", value: quotation.appliedAdvance)
                    SummaryRow(title: "Balance Due", value: quotation.balance, emphasized: true)
                }
                .padding(.top, 14)

                VStack(alignment: .leading, spacing: 7) {
                    Text("TERMS & CONDITIONS")
                        .font(.caption.bold())
                        .foregroundStyle(Color.sysyGold)
                    Text("• Final measurement will be confirmed before production.")
                    Text("• Quotation amount is based on the listed measurements and rates.")
                    Text("• Any additional work or material will be charged separately.")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 18)

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Customer Signature")
                            .font(.caption)
                        Rectangle()
                            .frame(width: 150, height: 1)
                    }
                    Spacer()
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Authorized Signature")
                            .font(.caption)
                        Rectangle()
                            .frame(width: 150, height: 1)
                    }
                }
                .foregroundStyle(.secondary)
                .padding(.top, 28)

                HStack {
                    Text("SYSY FAMILY")
                        .font(.caption.bold())
                    Spacer()
                    Text("Thank you for your business.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 22)

                Button {
                    showShare = true
                } label: {
                    Label("PDF তৈরি ও Share", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.sysyNavy)
                .padding(.top, 16)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Quotation Preview")
        .sheet(isPresented: $showShare) {
            PDFShareSheet(quotation: quotation)
        }
    }
}

struct SummaryRow: View {
    let title: String
    let value: Double
    var emphasized = false

    var body: some View {
        HStack {
            Text(title).fontWeight(emphasized ? .bold : .regular)
            Spacer()
            Text("MUR \(formatAmount(value))")
                .fontWeight(emphasized ? .bold : .regular)
                .foregroundStyle(emphasized ? Color.sysyGold : .primary)
        }
    }
}

struct QuotesView: View {
    @EnvironmentObject var store: AppDataStore
    @State private var searchText = ""
    @State private var selectedStatus: QuotationStatus?
    @State private var quotationPendingDelete: BusinessQuotation?
    @State private var sortMode: QuotationSortMode = .newest
    @State private var dateFilter: QuotationDateFilter = .all

    private enum QuotationDateFilter: String, CaseIterable, Identifiable {
        case all, today, last7Days, last30Days
        var id: String { rawValue }
        var title: String {
            switch self {
            case .all: return "সব তারিখ"
            case .today: return "আজ"
            case .last7Days: return "শেষ ৭ দিন"
            case .last30Days: return "শেষ ৩০ দিন"
            }
        }
        func matches(_ date: Date, now: Date = Date()) -> Bool {
            let calendar = Calendar.current
            switch self {
            case .all: return true
            case .today: return calendar.isDate(date, inSameDayAs: now)
            case .last7Days:
                guard let start = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: now)) else { return true }
                return date >= start && date <= now
            case .last30Days:
                guard let start = calendar.date(byAdding: .day, value: -29, to: calendar.startOfDay(for: now)) else { return true }
                return date >= start && date <= now
            }
        }
    }

    private enum QuotationSortMode: String, CaseIterable, Identifiable {
        case newest, oldest, highestAmount, lowestAmount, customerAZ
        var id: String { rawValue }
        var title: String {
            switch self {
            case .newest: return "নতুন আগে"
            case .oldest: return "পুরোনো আগে"
            case .highestAmount: return "বেশি Amount আগে"
            case .lowestAmount: return "কম Amount আগে"
            case .customerAZ: return "Customer A–Z"
            }
        }
    }

    private var filteredQuotes: [BusinessQuotation] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let all: [BusinessQuotation]
        switch sortMode {
        case .newest:
            all = store.data.quotations.sorted { $0.createdAt > $1.createdAt }
        case .oldest:
            all = store.data.quotations.sorted { $0.createdAt < $1.createdAt }
        case .highestAmount:
            all = store.data.quotations.sorted { $0.grandTotal > $1.grandTotal }
        case .lowestAmount:
            all = store.data.quotations.sorted { $0.grandTotal < $1.grandTotal }
        case .customerAZ:
            all = store.data.quotations.sorted { $0.customerName.localizedCaseInsensitiveCompare($1.customerName) == .orderedAscending }
        }
        return all.filter { quote in
            let matchesStatus = selectedStatus == nil || quote.status == selectedStatus
            let matchesSearch = q.isEmpty ||
                quote.number.localizedCaseInsensitiveContains(q) ||
                quote.customerName.localizedCaseInsensitiveContains(q) ||
                quote.phone.localizedCaseInsensitiveContains(q)
            let matchesDate = dateFilter.matches(quote.createdAt)
            return matchesStatus && matchesSearch && matchesDate
        }
    }

    /// Number of quotations matching search/date filters, before a status filter.
    private var baseFilteredQuotationCount: Int {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return store.data.quotations.filter { quote in
            let matchesSearch = q.isEmpty ||
                quote.number.localizedCaseInsensitiveContains(q) ||
                quote.customerName.localizedCaseInsensitiveContains(q) ||
                quote.phone.localizedCaseInsensitiveContains(q)
            return matchesSearch && dateFilter.matches(quote.createdAt)
        }.count
    }

    /// Counts each status using the active search/date filters, while ignoring
    /// the currently selected status so the chips remain useful for switching.
    private func statusCount(_ status: QuotationStatus) -> Int {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return store.data.quotations.filter { quote in
            let matchesSearch = q.isEmpty ||
                quote.number.localizedCaseInsensitiveContains(q) ||
                quote.customerName.localizedCaseInsensitiveContains(q) ||
                quote.phone.localizedCaseInsensitiveContains(q)
            let matchesDate = dateFilter.matches(quote.createdAt)
            return quote.status == status && matchesSearch && matchesDate
        }.count
    }

    private func updateStatus(for quotation: BusinessQuotation, to status: QuotationStatus) {
        guard let index = store.data.quotations.firstIndex(where: { $0.id == quotation.id }) else { return }
        store.data.quotations[index].status = status
    }

    private var filteredTotal: Double {
        filteredQuotes.reduce(0) { $0 + $1.grandTotal }
    }

    var body: some View {
        NavigationStack {
            Group {
                if filteredQuotes.isEmpty {
                    ContentUnavailableView(
                        searchText.isEmpty ? "কোনো Quotation নেই" : "Quotation পাওয়া যায়নি",
                        systemImage: searchText.isEmpty ? "doc.text" : "magnifyingglass",
                        description: Text(searchText.isEmpty ? "উপরের + বাটন দিয়ে নতুন Quotation তৈরি করুন।" : "No, customer name বা phone দিয়ে আবার খুঁজুন।")
                    )
                } else {
                    List {
                        ForEach(filteredQuotes) { quote in
                            NavigationLink(destination: QuotationPreviewView(quotation: quote)) {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(quote.number).font(.headline)
                                        Spacer()
                                        Menu {
                                            ForEach(QuotationStatus.allCases) { status in
                                                Button {
                                                    updateStatus(for: quote, to: status)
                                                } label: {
                                                    if status == quote.status {
                                                        Label(status.banglaTitle, systemImage: "checkmark")
                                                    } else {
                                                        Text(status.banglaTitle)
                                                    }
                                                }
                                            }
                                        } label: {
                                            HStack(spacing: 5) {
                                                Circle()
                                                    .fill(quote.status.uiColor)
                                                    .frame(width: 7, height: 7)
                                                Text(quote.status.banglaTitle)
                                            }
                                            .font(.caption2.bold())
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(quote.status.uiColor.opacity(0.12))
                                            .foregroundStyle(quote.status.uiColor)
                                            .clipShape(Capsule())
                                        }
                                        Text("MUR \(formatAmount(quote.grandTotal))")
                                            .bold().foregroundStyle(Color.sysyGold)
                                    }
                                    Text(quote.customerName)
                                    Text("Advance: MUR \(formatAmount(quote.appliedAdvance)) • বাকি: MUR \(formatAmount(quote.balance))")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text(quote.createdAt.formatted(date: .abbreviated, time: .omitted))
                                        .font(.caption2).foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                Button {
                                    store.duplicateQuotation(quote)
                                } label: {
                                    Label("Duplicate", systemImage: "plus.square.on.square")
                                }
                                .tint(Color.sysyGold)

                                NavigationLink(destination: EditQuotationView(quotation: quote)) {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(Color.sysyNavy)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    quotationPendingDelete = quote
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Quotation / Customer / Phone")
            .navigationTitle("কোটেশন")
            .safeAreaInset(edge: .top, spacing: 0) {
                if !filteredQuotes.isEmpty {
                    HStack {
                        Label("\(filteredQuotes.count) টি", systemImage: "doc.text")
                        Spacer()
                        Text("মোট MUR \(formatAmount(filteredTotal))")
                            .fontWeight(.semibold)
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                    .padding(.vertical, 7)
                    .background(.bar)
                }
                if !store.data.quotations.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            StatusFilterChip(title: "সব", count: baseFilteredQuotationCount, isSelected: selectedStatus == nil) {
                                selectedStatus = nil
                            }
                            ForEach(QuotationStatus.allCases) { status in
                                StatusFilterChip(title: status.banglaTitle, count: statusCount(status), isSelected: selectedStatus == status) {
                                    selectedStatus = selectedStatus == status ? nil : status
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                    .background(.bar)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Menu {
                        Section("Sort") {
                            Picker("Sort", selection: $sortMode) {
                                ForEach(QuotationSortMode.allCases) { mode in
                                    Text(mode.title).tag(mode)
                                }
                            }
                        }
                        Section("তারিখ") {
                            Picker("তারিখ", selection: $dateFilter) {
                                ForEach(QuotationDateFilter.allCases) { filter in
                                    Text(filter.title).tag(filter)
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                    NavigationLink(destination: QuotationBuilderView()) {
                        Image(systemName: "doc.badge.plus")
                    }
                }
            }
            .alert("Quotation Delete", isPresented: Binding(
                get: { quotationPendingDelete != nil },
                set: { if !$0 { quotationPendingDelete = nil } }
            )) {
                Button("Cancel", role: .cancel) { quotationPendingDelete = nil }
                Button("Delete", role: .destructive) {
                    if let quote = quotationPendingDelete {
                        store.data.quotations.removeAll { $0.id == quote.id }
                    }
                    quotationPendingDelete = nil
                }
            } message: {
                Text("এই quotation স্থায়ীভাবে মুছে ফেলা হবে।")
            }
        }
    }
}

struct StatusFilterChip: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Text(title)
                Text("\(count)")
                    .font(.caption2.bold())
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(isSelected ? Color.white.opacity(0.22) : Color.secondary.opacity(0.12))
                    .clipShape(Capsule())
            }
            .font(.caption.bold())
            .foregroundStyle(isSelected ? Color.white : Color.primary)
            .padding(.horizontal, 11)
            .padding(.vertical, 8)
            .background(isSelected ? Color.sysyNavy : Color(.secondarySystemBackground))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.secondary.opacity(isSelected ? 0 : 0.18)))
        }
        .buttonStyle(.plain)
    }
}

struct EditQuotationView: View {
    @EnvironmentObject var store: AppDataStore
    @Environment(\.dismiss) private var dismiss
    let quotation: BusinessQuotation

    @State private var customerName = ""
    @State private var phone = ""
    @State private var projectAddress = ""
    @State private var siteNote = ""
    @State private var status: QuotationStatus = .draft
    @State private var discountText = "0"
    @State private var advanceText = "0"
    @State private var lines: [QuotationLine] = []
    @State private var itemName = "Aluminium Door / Window"
    @State private var amountText = ""
    @State private var errorMessage = ""

    private var subtotal: Double { lines.reduce(0) { $0 + $1.amount } }
    private var discount: Double { max(0, Double(discountText) ?? 0) }
    private var advance: Double { max(0, Double(advanceText) ?? 0) }
    private var grandTotal: Double { max(0, subtotal - discount) }

    var body: some View {
        Form {
            Section("Customer") {
                TextField("Customer Name", text: $customerName)
                TextField("Phone", text: $phone).keyboardType(.phonePad)
                TextField("Project / Site Address", text: $projectAddress, axis: .vertical)
                TextField("Site Note", text: $siteNote, axis: .vertical)
                Picker("Status", selection: $status) {
                    ForEach(QuotationStatus.allCases) { item in
                        Text(item.banglaTitle).tag(item)
                    }
                }
            }

            Section("Items") {
                TextField("Item name", text: $itemName)
                TextField("Amount", text: $amountText).keyboardType(.decimalPad)
                Button("Item যোগ করুন") {
                    guard let amount = Double(amountText), amount > 0 else { return }
                    lines.append(QuotationLine(title: itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Item" : itemName.trimmingCharacters(in: .whitespacesAndNewlines), description: "Saved quotation item", amount: amount))
                    amountText = ""
                }
                ForEach(lines) { line in
                    HStack {
                        Text(line.title)
                        Spacer()
                        Text("MUR \(formatAmount(line.amount))")
                    }
                }
                .onDelete { lines.remove(atOffsets: $0) }
            }

            Section("Payment") {
                HStack { Text("Subtotal"); Spacer(); Text("MUR \(formatAmount(subtotal))") }
                TextField("Discount", text: $discountText).keyboardType(.decimalPad)
                if discount > subtotal { Text("Discount subtotal-এর চেয়ে বেশি হতে পারবে না").font(.caption).foregroundStyle(.red) }
                TextField("Advance", text: $advanceText).keyboardType(.decimalPad)
                if advance > grandTotal { Text("Advance Grand Total-এর চেয়ে বেশি হতে পারবে না").font(.caption).foregroundStyle(.red) }
                HStack { Text("Grand Total").bold(); Spacer(); Text("MUR \(formatAmount(grandTotal))").bold() }
            }

            if !errorMessage.isEmpty {
                Text(errorMessage).font(.caption).foregroundStyle(.red)
            }

            Button("Quotation Update করুন") { updateQuotation() }
                .buttonStyle(.borderedProminent)
                .disabled(customerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || lines.isEmpty || discount > subtotal || advance > grandTotal)
        }
        .navigationTitle("Quotation Edit")
        .onAppear {
            customerName = quotation.customerName
            phone = quotation.phone
            projectAddress = quotation.projectAddress
            siteNote = quotation.siteNote
            status = quotation.status
            discountText = String(quotation.discount)
            advanceText = String(quotation.advance)
            lines = quotation.lines
        }
    }

    private func updateQuotation() {
        let trimmedName = customerName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty, !lines.isEmpty else { return }
        guard discount <= subtotal else { errorMessage = "Discount ঠিক করুন"; return }
        guard advance <= grandTotal else { errorMessage = "Advance ঠিক করুন"; return }
        guard let index = store.data.quotations.firstIndex(where: { $0.id == quotation.id }) else { return }
        store.data.quotations[index] = BusinessQuotation(
            id: quotation.id,
            number: quotation.number,
            customerName: trimmedName,
            phone: phone.trimmingCharacters(in: .whitespacesAndNewlines),
            projectAddress: projectAddress,
            siteNote: siteNote.trimmingCharacters(in: .whitespacesAndNewlines),
            status: status,
            lines: lines,
            discount: discount,
            advance: min(advance, grandTotal),
            createdAt: quotation.createdAt,
            advanceDate: {
                let newAdvance = min(advance, grandTotal)
                if newAdvance <= 0 { return nil }
                if abs(newAdvance - quotation.advance) < 0.01 { return quotation.advanceDate }
                return Date()
            }()
        )
        dismiss()
    }
}

struct QuoteDetailView: View {
    let quote: Quote
    @State private var showPDFShare = false

    private var businessQuotation: BusinessQuotation {
        BusinessQuotation(
            id: quote.id,
            number: quote.number,
            customerName: quote.customer.name,
            phone: quote.customer.phone,
            projectAddress: quote.customer.projectAddress,
            siteNote: quote.customer.siteNote,
            lines: quote.items.map { item in
                QuotationLine(
                    title: item.title,
                    description: "\(item.width, specifier: "%.2f") × \(item.height, specifier: "%.2f") × \(item.quantity)",
                    amount: item.amount
                )
            },
            discount: 0,
            advance: quote.advance
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                AppCard {
                    HStack {
                        SYSYLogoView()
                            .frame(width: 70, height: 70)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        VStack(alignment: .leading) {
                            Text("SYSY FAMILY").font(.title2.bold())
                            Text("Aluminium Door & Window Solutions")
                                .font(.caption)
                        }
                        Spacer()
                    }
                }
                AppCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("QUOTATION").font(.title3.bold())
                        Text("No: \(quote.number)")
                        Text("Customer: \(quote.customer.name)")
                        Text("Phone: \(quote.customer.phone)")
                        Divider()
                        ForEach(quote.items) { item in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(item.title)
                                    Text("\(item.sqft, specifier: "%.1f") Sqft × MUR \(formatAmount(item.rate))")
                                        .font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text("MUR \(formatAmount(item.amount))")
                            }
                        }
                        Divider()
                        HStack {
                            Text("Grand Total").bold()
                            Spacer()
                            Text("MUR \(formatAmount(quote.subtotal))").bold().foregroundStyle(Color.sysyGold)
                        }
                    }
                }
                Button("PDF তৈরি / শেয়ার") {
                    showPDFShare = true
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.sysyNavy)
                .sheet(isPresented: $showPDFShare) {
                    PDFShareSheet(quotation: businessQuotation)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Quotation")
    }
}




struct ProjectDetailsView: View {
    @EnvironmentObject var store: AppDataStore
    let customer: Customer

    @State private var projectAddress = ""
    @State private var siteNote = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoCount = 0

    var body: some View {
        Form {
            Section("Customer") {
                Text(customer.name).font(.headline)
                Text(customer.phone)
            }

            Section("Project / Site Address") {
                TextField("Site Address", text: $projectAddress, axis: .vertical)
                    .lineLimit(3...5)
                TextField("Site Note", text: $siteNote, axis: .vertical)
                    .lineLimit(2...4)
            }

            Section("কাজের ছবি") {
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    Label("Site / Work Photo যোগ করুন", systemImage: "photo.badge.plus")
                }
                if photoCount > 0 {
                    Text("\(photoCount)টি ছবি যোগ করা হয়েছে")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("এখনও কোনো ছবি যোগ করা হয়নি")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                Button("Project Details Save করুন") {
                    if let index = store.data.customers.firstIndex(where: { $0.id == customer.id }) {
                        store.data.customers[index].projectAddress = projectAddress
                        store.data.customers[index].siteNote = siteNote
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.sysyNavy)
            }
        }
        .navigationTitle("Project Details")
        .onAppear {
            projectAddress = customer.projectAddress
            siteNote = customer.siteNote
            photoCount = customer.photoFileNames.count
        }
        .onChange(of: selectedPhoto) { _, newItem in
            if newItem != nil {
                photoCount += 1
                selectedPhoto = nil
            }
        }
    }
}


struct CustomerSummaryPDFShareSheet: UIViewControllerRepresentable {
    let customer: Customer
    let quotations: [BusinessQuotation]
    let payments: [PaymentRecord]
    let measurements: [CustomerMeasurement]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let data = makePDF()
        let safeName = customer.name.replacingOccurrences(of: "/", with: "-")
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("SYSY-FAMILY-\(safeName)-Summary.pdf")
        try? data.write(to: url, options: .atomic)
        return UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }

    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}

    private func makePDF() -> Data {
        let page = CGRect(x: 0, y: 0, width: 595, height: 842)
        let margin: CGFloat = 40
        let renderer = UIGraphicsPDFRenderer(bounds: page)
        let sales = quotations.reduce(0) { $0 + $1.grandTotal }
        let advances = quotations.reduce(0) { $0 + $1.appliedAdvance }
        let extraPayments = payments.reduce(0) { $0 + $1.amount }
        let paid = advances + extraPayments
        let due = max(0, sales - paid)

        return renderer.pdfData { context in
            var y: CGFloat = margin
            context.beginPage()

            func draw(_ text: String, size: CGFloat = 11, bold: Bool = false, color: UIColor = .label, gap: CGFloat = 7) {
                let font = bold ? UIFont.boldSystemFont(ofSize: size) : UIFont.systemFont(ofSize: size)
                let paragraph = NSMutableParagraphStyle()
                paragraph.lineBreakMode = .byWordWrapping
                let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color, .paragraphStyle: paragraph]
                let rect = (text as NSString).boundingRect(
                    with: CGSize(width: page.width - margin * 2, height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: attributes,
                    context: nil
                )
                let height = ceil(rect.height)
                if y + height > page.height - margin {
                    context.beginPage()
                    y = margin
                    drawHeader()
                }
                (text as NSString).draw(
                    in: CGRect(x: margin, y: y, width: page.width - margin * 2, height: height),
                    withAttributes: attributes
                )
                y += height + gap
            }

            func drawHeader() {
                // Small geometric SYSY brand mark, matching the app's navy/gold identity.
                let mark = CGRect(x: page.width - margin - 25, y: y + 1, width: 25, height: 25)
                UIColor(red: 0.82, green: 0.60, blue: 0.18, alpha: 1).setStroke()
                UIBezierPath(roundedRect: mark, cornerRadius: 4).stroke()
                draw("SYSY FAMILY", size: 22, bold: true, color: UIColor(red: 0.02, green: 0.08, blue: 0.18, alpha: 1), gap: 2)
                draw("Aluminium Door & Window Solutions", size: 11, gap: 2)
                draw("Mobile: +230 5890 9358", size: 10, color: .darkGray, gap: 10)
                y += 2
            }

            drawHeader()
            draw("CUSTOMER WORK & ACCOUNT SUMMARY", size: 16, bold: true, gap: 10)
            draw("Customer: \(customer.name)", size: 12, bold: true, gap: 3)
            draw("Phone: \(customer.phone)", gap: 3)
            draw("Address: \(customer.address.isEmpty ? "—" : customer.address)", gap: 3)
            draw("Work site: \(customer.projectAddress.isEmpty ? "—" : customer.projectAddress)", gap: 3)
            if !customer.siteNote.isEmpty { draw("Site notes: \(customer.siteNote)", gap: 8) }

            draw("ACCOUNT SUMMARY", size: 12, bold: true, color: UIColor.systemBlue, gap: 4)
            draw("Total Sales: MUR \(formatAmount(sales))", gap: 3)
            draw("Total Paid: MUR \(formatAmount(paid))", gap: 3)
            draw("Balance Due: MUR \(formatAmount(due))", size: 12, bold: true, gap: 10)

            draw("MEASUREMENTS", size: 12, bold: true, color: UIColor.systemBlue, gap: 4)
            if measurements.isEmpty {
                draw("No saved measurements.", color: .secondaryLabel)
            } else {
                for item in measurements {
                    draw("\(item.title) — \(String(format: "%.2f", item.width)) × \(String(format: "%.2f", item.height)) × \(item.quantity) = \(String(format: "%.2f", item.sqft)) Sqft", gap: 2)
                    draw("Amount: MUR \(formatAmount(item.amount))", size: 10, color: .secondaryLabel, gap: 6)
                }
            }

            draw("QUOTATION HISTORY", size: 12, bold: true, color: UIColor.systemBlue, gap: 4)
            if quotations.isEmpty {
                draw("No quotations.", color: .secondaryLabel)
            } else {
                for quote in quotations.sorted(by: { $0.createdAt > $1.createdAt }) {
                    draw("\(quote.number) • \(quote.createdAt.formatted(date: .abbreviated, time: .omitted))", bold: true, gap: 2)
                    draw("Status: \(quote.status.rawValue) • Total: MUR \(formatAmount(quote.grandTotal)) • Advance: MUR \(formatAmount(quote.appliedAdvance)) • Due: MUR \(formatAmount(quote.balance))", size: 10, gap: 6)
                }
            }

            draw("PAYMENT HISTORY", size: 12, bold: true, color: UIColor.systemBlue, gap: 4)
            if payments.isEmpty {
                draw("No separate payment records.", color: .secondaryLabel)
            } else {
                for payment in payments.sorted(by: { $0.date > $1.date }) {
                    draw("\(payment.date.formatted(date: .abbreviated, time: .omitted)) • \(payment.note.isEmpty ? "Payment" : payment.note)", bold: true, gap: 2)
                    draw("Received: MUR \(formatAmount(payment.amount))", size: 10, gap: 6)
                }
            }
            draw("Generated by SYSY FAMILY • +230 5890 9358", size: 9, color: .secondaryLabel, gap: 0)
        }
    }
}

struct CustomerAccountDetailsView: View {
    @EnvironmentObject var store: AppDataStore
    let customer: Customer
    @State private var showCustomerPDF = false
    @State private var editingCustomerMeasurement: CustomerMeasurement?
    @State private var customerMeasurementToDelete: CustomerMeasurement?

    private var customerQuotes: [BusinessQuotation] {
        store.data.quotations.filter {
            $0.customerName.caseInsensitiveCompare(customer.name) == .orderedSame
        }.sorted { $0.createdAt > $1.createdAt }
    }

    private var customerPayments: [PaymentRecord] {
        store.data.payments.filter {
            $0.customerName.caseInsensitiveCompare(customer.name) == .orderedSame
        }
    }

    private var customerMeasurements: [CustomerMeasurement] {
        store.data.measurements.filter {
            $0.customerName.caseInsensitiveCompare(customer.name) == .orderedSame
        }
    }

    private var totalSales: Double {
        customerQuotes.reduce(0) { $0 + $1.grandTotal }
    }

    private var quotationAdvance: Double {
        customerQuotes.reduce(0) { $0 + $1.appliedAdvance }
    }

    private var paymentRecordsTotal: Double {
        customerPayments.reduce(0) { $0 + $1.amount }
    }

    private var totalPaid: Double {
        quotationAdvance + paymentRecordsTotal
    }

    private var due: Double {
        max(0, totalSales - totalPaid)
    }

    var body: some View {
        List {
            Section("Customer") {
                HStack(spacing: 12) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(Color.sysyGold)
                    VStack(alignment: .leading) {
                        Text(customer.name).font(.headline)
                        Text(customer.phone)
                        Text(customer.address)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("Project") {
                NavigationLink(destination: ProjectDetailsView(customer: customer)) {
                    Label("Project / Site Details", systemImage: "mappin.and.ellipse")
                }
            }

            Section("Measurements") {
                if customerMeasurements.isEmpty {
                    Text("এই customer-এর measurement নেই। Work tab থেকে নতুন measurement যোগ করুন।")
                        .font(.footnote).foregroundStyle(.secondary)
                } else {
                    ForEach(customerMeasurements) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.title).font(.headline)
                            Text("\(String(format: "%.2f", item.width)) × \(String(format: "%.2f", item.height)) × \(item.quantity) = \(String(format: "%.2f", item.sqft)) Sqft")
                                .font(.caption).foregroundStyle(.secondary)
                            Text("MUR \(formatAmount(item.amount))").bold().foregroundStyle(Color.sysyGold)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button {
                                editingCustomerMeasurement = item
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }.tint(.blue)
                            Button(role: .destructive) {
                                customerMeasurementToDelete = item
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }

            Section("Account Summary") {
                AccountAmountRow(title: "মোট Sales", amount: totalSales)
                AccountAmountRow(title: "Quotation Advance", amount: quotationAdvance, color: .green)
                AccountAmountRow(title: "Payment Records", amount: paymentRecordsTotal, color: .green)
                AccountAmountRow(title: "মোট Paid", amount: totalPaid, color: .green)
                AccountAmountRow(title: "মোট বাকি", amount: due, color: .red)
            }

            Section("Quotation History") {
                if customerQuotes.isEmpty {
                    Text("এই customer-এর কোনো quotation নেই")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(customerQuotes) { quote in
                        VStack(alignment: .leading, spacing: 5) {
                            Text(quote.number).font(.headline)
                            Text(quote.createdAt.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text("Grand Total: MUR \(formatAmount(quote.grandTotal))")
                            Text("Advance: MUR \(formatAmount(quote.appliedAdvance)) • Balance: MUR \(formatAmount(quote.balance))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                store.data.quotations.removeAll { $0.id == quote.id }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }

            Section("Payment History") {
                if customerPayments.isEmpty {
                    Text("এই customer-এর কোনো payment নেই")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(customerPayments) { payment in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(payment.note.isEmpty ? "Payment" : payment.note)
                                Text(payment.date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text("MUR \(formatAmount(payment.amount))")
                                .bold()
                                .foregroundStyle(.green)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                store.data.payments.removeAll { $0.id == payment.id }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Customer Account")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showCustomerPDF = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                .accessibilityLabel("Customer PDF share")
            }
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(destination: EditCustomerView(customer: customer)) {
                    Image(systemName: "pencil")
                }
            }
        }
        .sheet(isPresented: $showCustomerPDF) {
            CustomerSummaryPDFShareSheet(
                customer: customer,
                quotations: customerQuotes,
                payments: customerPayments,
                measurements: customerMeasurements
            )
        }
        .sheet(item: $editingCustomerMeasurement) { item in
            EditMeasurementView(measurement: item).environmentObject(store)
        }
        .alert("Measurement Delete", isPresented: Binding(
            get: { customerMeasurementToDelete != nil },
            set: { if !$0 { customerMeasurementToDelete = nil } }
        )) {
            Button("Cancel", role: .cancel) { customerMeasurementToDelete = nil }
            Button("Delete", role: .destructive) {
                if let item = customerMeasurementToDelete {
                    var updated = store.data
                    updated.measurements.removeAll { $0.id == item.id }
                    store.data = updated
                }
                customerMeasurementToDelete = nil
            }
        } message: {
            Text("এই measurement মুছে ফেললে আর ফেরত পাওয়া যাবে না।")
        }
    }
}

struct EditCustomerView: View {
    @EnvironmentObject var store: AppDataStore
    @Environment(\.dismiss) private var dismiss
    let customer: Customer
    @State private var name = ""
    @State private var phone = ""
    @State private var address = ""
    @State private var projectAddress = ""
    @State private var siteNote = ""

    var body: some View {
        Form {
            Section("কাস্টমার তথ্য") {
                TextField("নাম", text: $name)
                TextField("ফোন", text: $phone).keyboardType(.phonePad)
                TextField("ঠিকানা", text: $address)
                TextField("Project / Site Address", text: $projectAddress)
                TextField("Site Note", text: $siteNote, axis: .vertical)
                    .lineLimit(3...6)
            }
        }
        .navigationTitle("Customer Edit")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("বাতিল") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("সেভ") {
                    let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmedName.isEmpty,
                          let index = store.data.customers.firstIndex(where: { $0.id == customer.id }) else { return }
                    let oldName = store.data.customers[index].name
                    store.data.customers[index].name = trimmedName
                    store.data.customers[index].phone = phone
                    store.data.customers[index].address = address
                    store.data.customers[index].projectAddress = projectAddress
                    store.data.customers[index].siteNote = siteNote
                    if oldName != trimmedName {
                        for i in store.data.quotations.indices where store.data.quotations[i].customerName == oldName {
                            store.data.quotations[i].customerName = trimmedName
                            store.data.quotations[i].phone = phone
                        }
                        for i in store.data.payments.indices where store.data.payments[i].customerName == oldName {
                            store.data.payments[i].customerName = trimmedName
                        }
                        for i in store.data.measurements.indices where store.data.measurements[i].customerName == oldName {
                            store.data.measurements[i].customerName = trimmedName
                        }
                    }
                    dismiss()
                }
            }
        }
        .onAppear {
            name = customer.name
            phone = customer.phone
            address = customer.address
            projectAddress = customer.projectAddress
            siteNote = customer.siteNote
        }
    }
}

struct AccountAmountRow: View {
    let title: String
    let amount: Double
    var color: Color = .primary

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text("MUR \(formatAmount(amount))")
                .bold()
                .foregroundStyle(color)
        }
    }
}

struct CustomerHistoryView: View {
    @EnvironmentObject var store: AppDataStore
    let customer: Customer
    let quotations: [BusinessQuotation]
    let payments: [PaymentRecord]

    private var quoted: Double { quotations.reduce(0) { $0 + $1.grandTotal } }
    private var quotationAdvance: Double { quotations.reduce(0) { $0 + $1.appliedAdvance } }
    private var paymentRecordsTotal: Double { payments.reduce(0) { $0 + $1.amount } }
    private var paid: Double { quotationAdvance + paymentRecordsTotal }
    private var due: Double { max(0, quoted - paid) }

    var body: some View {
        List {
            Section("Customer") {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 42))
                        .foregroundStyle(Color.sysyGold)
                    VStack(alignment: .leading) {
                        Text(customer.name).font(.headline)
                        Text(customer.phone)
                        Text(customer.address)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("হিসাব") {
                HistoryMoneyRow(title: "মোট Quotation", value: quoted, color: .primary)
                HistoryMoneyRow(title: "Quotation Advance", value: quotationAdvance, color: .green)
                HistoryMoneyRow(title: "Payment Records", value: paymentRecordsTotal, color: .green)
                HistoryMoneyRow(title: "মোট Paid", value: paid, color: .green)
                HistoryMoneyRow(title: "মোট বাকি", value: due, color: .red)
            }

            Section("Quotation History") {
                if quotations.isEmpty {
                    Text("এখনও কোনো quotation নেই")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(quotations) { quote in
                        VStack(alignment: .leading, spacing: 5) {
                            Text(quote.number).font(.headline)
                            Text(quote.createdAt.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text("Grand Total: MUR \(formatAmount(quote.grandTotal))")
                            Text("Advance: MUR \(formatAmount(quote.appliedAdvance)) • Balance: MUR \(formatAmount(quote.balance))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                store.data.quotations.removeAll { $0.id == quote.id }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }

            Section("Payment History") {
                if payments.isEmpty {
                    Text("এখনও কোনো payment নেই")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(payments) { payment in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(payment.note.isEmpty ? "Payment" : payment.note)
                                Text(payment.date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text("MUR \(formatAmount(payment.amount))")
                                .bold()
                                .foregroundStyle(.green)
                        }
                    }
                }
            }
        }
        .navigationTitle("Customer History")
    }
}

struct HistoryMoneyRow: View {
    let title: String
    let value: Double
    let color: Color

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text("MUR \(formatAmount(value))")
                .bold()
                .foregroundStyle(color)
        }
    }
}


struct PaymentReceiptPDFShareSheet: UIViewControllerRepresentable {
    let payment: PaymentRecord

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let data = makePDF()
        let safeName = payment.customerName.replacingOccurrences(of: "/", with: "-")
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("SYSY-FAMILY-Receipt-\(safeName).pdf")
        try? data.write(to: url, options: .atomic)
        return UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }

    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}

    private func makePDF() -> Data {
        let page = CGRect(x: 0, y: 0, width: 595, height: 842)
        let margin: CGFloat = 42
        let renderer = UIGraphicsPDFRenderer(bounds: page)
        return renderer.pdfData { context in
            context.beginPage()
            // SYSY FAMILY brand mark.
            let mark = CGRect(x: page.width - margin - 26, y: margin, width: 24, height: 24)
            UIColor(red: 0.82, green: 0.60, blue: 0.18, alpha: 1).setStroke()
            UIBezierPath(roundedRect: mark, cornerRadius: 4).stroke()

            func draw(_ text: String, size: CGFloat = 12, bold: Bool = false, color: UIColor = .label, y: CGFloat) {
                let font = bold ? UIFont.boldSystemFont(ofSize: size) : UIFont.systemFont(ofSize: size)
                let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
                (text as NSString).draw(at: CGPoint(x: margin, y: y), withAttributes: attributes)
            }

            draw("SYSY FAMILY", size: 24, bold: true, color: UIColor(red: 0.02, green: 0.08, blue: 0.18, alpha: 1), y: margin)
            draw("Aluminium Door & Window Solutions", size: 12, y: margin + 34)
            draw("Mobile: +230 5890 9358", size: 11, color: .darkGray, y: margin + 54)

            let line = UIBezierPath()
            line.move(to: CGPoint(x: margin, y: margin + 82))
            line.addLine(to: CGPoint(x: page.width - margin, y: margin + 82))
            UIColor.separator.setStroke()
            line.stroke()

            draw("PAYMENT RECEIPT", size: 20, bold: true, y: margin + 105)
            draw("Receipt date: \(payment.date.formatted(date: .long, time: .shortened))", y: margin + 145)
            draw("Received from: \(payment.customerName)", size: 14, bold: true, y: margin + 180)
            draw("Amount received: MUR \(formatAmount(payment.amount))", size: 18, bold: true, color: UIColor.systemGreen, y: margin + 220)
            draw("Payment note: \(payment.note.isEmpty ? "—" : payment.note)", y: margin + 260)
            draw("Thank you for your payment.", size: 12, color: .darkGray, y: margin + 320)
            draw("SYSY FAMILY • +230 5890 9358", size: 10, color: .secondaryLabel, y: page.height - margin - 20)
        }
    }
}

struct PaymentTrackingView: View {
    @State private var customerName = ""
    @State private var amount = ""
    @State private var note = ""
    @State private var showValidation = false
    @State private var validationMessage = ""
    @State private var paymentForReceipt: PaymentRecord?
    @EnvironmentObject var store: AppDataStore

    private var totalPaid: Double {
        store.data.quotations.reduce(0) { $0 + $1.appliedAdvance }
        + store.data.payments.reduce(0) { $0 + $1.amount }
    }

    private var customerSales: Double {
        let name = customerName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return 0 }
        return store.data.quotations
            .filter { $0.customerName.caseInsensitiveCompare(name) == .orderedSame }
            .reduce(0) { $0 + $1.grandTotal }
    }

    private var customerAdvance: Double {
        let name = customerName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return 0 }
        return store.data.quotations
            .filter { $0.customerName.caseInsensitiveCompare(name) == .orderedSame }
            .reduce(0) { $0 + $1.appliedAdvance }
    }

    private var customerPaid: Double {
        let name = customerName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return 0 }
        return store.data.payments
            .filter { $0.customerName.caseInsensitiveCompare(name) == .orderedSame }
            .reduce(0) { $0 + $1.amount }
    }

    private var customerDue: Double {
        max(0, customerSales - customerAdvance - customerPaid)
    }

    private var sortedPayments: [PaymentRecord] {
        store.data.payments.sorted { $0.date > $1.date }
    }

    var body: some View {
        Form {
            Section("নতুন Payment") {
                TextField("Customer Name", text: $customerName)
                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)
                TextField("Note", text: $note)

                if !customerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Customer Due")
                            if customerAdvance > 0 {
                                Text("Quotation advance: MUR \(formatAmount(customerAdvance))")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        Text("MUR \(formatAmount(customerDue))")
                            .bold()
                            .foregroundStyle(customerDue > 0 ? .red : .green)
                    }
                }

                Button("Payment Save করুন") {
                    let name = customerName.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard let value = Double(amount), value > 0, !name.isEmpty else {
                        validationMessage = "Customer name এবং valid payment amount দিন।"
                        showValidation = true
                        return
                    }

                    if customerSales > 0 && value > customerDue + 0.01 {
                        validationMessage = "এই customer-এর বাকি MUR \(formatAmount(customerDue))। এর বেশি payment যোগ করা যাবে না।"
                        showValidation = true
                        return
                    }

                    let normalizedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
                    let duplicateToday = store.data.payments.contains {
                        $0.customerName.caseInsensitiveCompare(name) == .orderedSame &&
                        abs($0.amount - value) < 0.005 &&
                        $0.note == normalizedNote &&
                        Calendar.current.isDate($0.date, inSameDayAs: Date())
                    }
                    if duplicateToday {
                        validationMessage = "একই Customer-এর একই Amount ও Note-এর Payment আজ আগে থেকেই আছে। Save করার আগে যাচাই করুন।"
                        showValidation = true
                        return
                    }

                    store.addPayment(
                        PaymentRecord(
                            customerName: name,
                            amount: value,
                            date: Date(),
                            note: note.trimmingCharacters(in: .whitespacesAndNewlines)
                        )
                    )
                    customerName = ""
                    amount = ""
                    note = ""
                }
            }

            Section("এই device-এ recorded payment") {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("মোট Collection").bold()
                        Text("Quotation advance + Payment")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text("MUR \(formatAmount(totalPaid))")
                        .bold()
                        .foregroundStyle(.green)
                }

                ForEach(sortedPayments) { payment in
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(payment.customerName).font(.headline)
                            Text(payment.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            if !payment.note.isEmpty {
                                Text(payment.note)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        Text("MUR \(formatAmount(payment.amount))")
                            .foregroundStyle(.green)
                        Button {
                            paymentForReceipt = payment
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                        .buttonStyle(.borderless)
                        .accessibilityLabel("PDF receipt share")
                    }
                }
                .onDelete { offsets in
                    let ids = offsets.map { sortedPayments[$0].id }
                    store.data.payments.removeAll { ids.contains($0.id) }
                }
            }
        }
        .navigationTitle("Payment Tracking")
        .alert("Payment Check", isPresented: $showValidation) {
            Button("ঠিক আছে", role: .cancel) { }
        } message: {
            Text(validationMessage)
        }
        .sheet(item: $paymentForReceipt) { payment in
            PaymentReceiptPDFShareSheet(payment: payment)
        }
    }
}



struct DataStorageView: View {
    @EnvironmentObject var store: AppDataStore
    @State private var showReset = false

    var body: some View {
        List {
            Section("Data Status") {
                StorageRow(title: "Customer", value: store.data.customers.count)
                StorageRow(title: "Quotation", value: store.data.quotations.count)
                StorageRow(title: "Payment", value: store.data.payments.count)
                StorageRow(title: "Rate", value: store.data.rates.count)
            }

            Section("Automatic Save") {
                Label("Data app-এর ভিতরে automatically save হবে", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Text("App বন্ধ করলেও saved data থাকবে। Backup feature-এর মাধ্যমে আলাদা backup file রাখা যাবে।")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section {
                Button(role: .destructive) {
                    showReset = true
                } label: {
                    Label("সব Data মুছে ফেলুন", systemImage: "trash")
                }
            }
        }
        .navigationTitle("Data Storage")
        .alert("সব Data মুছে ফেলবেন?", isPresented: $showReset) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                store.clearAll()
            }
        } message: {
            Text("এই কাজটি করলে saved Customer, Quotation, Payment এবং Rate data মুছে যাবে।")
        }
    }
}

struct StorageRow: View {
    let title: String
    let value: Int

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text("\(value)")
                .bold()
                .foregroundStyle(Color.sysyGold)
        }
    }
}

struct BackupView: View {
    @EnvironmentObject var store: AppDataStore
    @State private var showImporter = false
    @State private var showExporter = false
    @State private var backupDocument: BackupDocument?
    @State private var status = ""
    @State private var statusIsError = false
    @State private var pendingRestore: BackupData?
    @State private var showRestoreConfirmation = false
    @AppStorage("SYSY_FAMILY_LAST_BACKUP_DATE") private var lastBackupDate: Double = 0

    var body: some View {
        List {
            Section("Backup") {
                Text("Customer: \(store.data.customers.count) • Quotation: \(store.data.quotations.count)")
                    .font(.subheadline)
                Text("Payment: \(store.data.payments.count) • Rate: \(store.data.rates.count) • Measurement: \(store.data.measurements.count)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Label("V63 backup-এ checksum + restore validation থাকবে", systemImage: "checkmark.shield.fill")
                    .font(.caption)
                    .foregroundStyle(.green)
                Button {
                    let now = Date()
                    let payload = BackupData(exportedAt: now, appName: "SYSY FAMILY", version: "63", appData: store.data)
                    guard let data = try? JSONEncoder().encode(payload) else { return }
                    backupDocument = BackupDocument(data: data)
                    showExporter = true
                } label: {
                    Label("সম্পূর্ণ Backup File তৈরি করুন", systemImage: "arrow.up.doc")
                }
                if lastBackupDate > 0 {
                    Label("শেষ Backup: \(Date(timeIntervalSince1970: lastBackupDate).formatted(date: .abbreviated, time: .shortened))", systemImage: "clock.arrow.circlepath")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if store.canUndoLastRestore {
                    Button {
                        if store.undoLastRestore() {
                            statusIsError = false
                            status = "শেষ Restore Undo করা হয়েছে — আগের data ফিরে এসেছে"
                        }
                    } label: {
                        Label("শেষ Restore Undo করুন", systemImage: "arrow.uturn.backward.circle")
                    }
                }
                Button { showImporter = true } label: {
                    Label("Backup Restore করুন", systemImage: "arrow.down.doc")
                }
            }
            if !status.isEmpty {
                Section { Label(status, systemImage: statusIsError ? "exclamationmark.triangle.fill" : "checkmark.circle.fill").foregroundStyle(statusIsError ? .red : .green) }
            }
            Section("Backup-এ থাকবে") {
                Label("Customer + Project/Site তথ্য", systemImage: "person.2")
                Label("Measurements + Rate List", systemImage: "ruler")
                Label("Quotation + Payment records", systemImage: "doc.text")
            }
        }
        .navigationTitle("Backup")
        .alert("Backup Restore নিশ্চিত করুন", isPresented: $showRestoreConfirmation) {
            Button("Restore করুন", role: .destructive) {
                guard let payload = pendingRestore else { return }
                store.restore(payload.appData)
                pendingRestore = nil
                statusIsError = false
                status = "Backup সফলভাবে Restore হয়েছে (V\(payload.version)) — data validation passed"
            }
            Button("Cancel", role: .cancel) {
                pendingRestore = nil
                statusIsError = false
                status = "Restore বাতিল করা হয়েছে"
            }
        } message: {
            if let payload = pendingRestore {
                Text("এই backup restore করলে বর্তমান Customer, Quotation, Payment, Rate ও Measurement data replace হবে। Backup: V\(payload.version) • Customer: \(payload.appData.customers.count) • Quotation: \(payload.appData.quotations.count) • Payment: \(payload.appData.payments.count)")
            } else {
                Text("বর্তমান data replace হবে।")
            }
        }
        .fileExporter(isPresented: $showExporter, document: backupDocument ?? BackupDocument(data: Data()), contentType: .json, defaultFilename: "SYSY_FAMILY_Backup_v63.json") { result in
            if case .success = result { statusIsError = false; lastBackupDate = Date().timeIntervalSince1970
                status = "Backup সফলভাবে তৈরি হয়েছে (V63)" }
        }
        .fileImporter(isPresented: $showImporter, allowedContentTypes: [.json], allowsMultipleSelection: false) { result in
            guard case .success(let urls) = result, let url = urls.first else {
                statusIsError = true
                status = "Backup file নির্বাচন করা হয়নি"
                return
            }

            let didStartSecurityScope = url.startAccessingSecurityScopedResource()
            defer {
                if didStartSecurityScope { url.stopAccessingSecurityScopedResource() }
            }

            guard let data = try? Data(contentsOf: url),
                  let payload = try? JSONDecoder().decode(BackupData.self, from: data) else {
                statusIsError = true
                status = "Backup file সঠিক নয় বা পড়া যায়নি"
                return
            }
            if let validationError = payload.restoreValidationMessage {
                statusIsError = true
                status = validationError + " — Restore করা হয়নি"
                return
            }
            pendingRestore = payload
            showRestoreConfirmation = true
        }
    }
}

struct BackupDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    var data: Data
    init(data: Data) { self.data = data }
    init(configuration: ReadConfiguration) throws { data = configuration.file.regularFileContents ?? Data() }
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper { FileWrapper(regularFileWithContents: data) }
}

struct PaymentsView: View {
    @EnvironmentObject var store: AppDataStore
    @State private var searchText = ""

    private struct LedgerRow: Identifiable {
        let customer: Customer
        let lastDate: Date?
        let sales: Double
        let advance: Double
        let paidLater: Double
        var paid: Double { advance + paidLater }
        var due: Double { max(0, sales - paid) }
        var id: UUID { customer.id }
    }

    private var ledgerRows: [LedgerRow] {
        store.data.customers.map { customer in
            let quotes = store.data.quotations.filter {
                $0.customerName.caseInsensitiveCompare(customer.name) == .orderedSame
            }
            let payments = store.data.payments.filter {
                $0.customerName.caseInsensitiveCompare(customer.name) == .orderedSame
            }
            return LedgerRow(
                customer: customer,
                lastDate: quotes.map(\.createdAt).max(),
                sales: quotes.reduce(0) { $0 + $1.grandTotal },
                advance: quotes.reduce(0) { $0 + $1.appliedAdvance },
                paidLater: payments.reduce(0) { $0 + $1.amount }
            )
        }
        .filter { row in
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            return query.isEmpty ||
                row.customer.name.localizedCaseInsensitiveContains(query) ||
                row.customer.phone.localizedCaseInsensitiveContains(query) ||
                row.customer.address.localizedCaseInsensitiveContains(query)
        }
        .sorted { $0.customer.name.localizedCaseInsensitiveCompare($1.customer.name) == .orderedAscending }
    }

    private var filteredSales: Double { ledgerRows.reduce(0) { $0 + $1.sales } }
    private var filteredAdvance: Double { ledgerRows.reduce(0) { $0 + $1.advance } }
    private var filteredLaterPayments: Double { ledgerRows.reduce(0) { $0 + $1.paidLater } }
    private var filteredDue: Double { ledgerRows.reduce(0) { $0 + $1.due } }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ledgerSummary(title: "মোট বিক্রি", amount: filteredSales, color: Color.sysyNavy, icon: "chart.bar.fill")
                        ledgerSummary(title: "মোট অগ্রিম", amount: filteredAdvance, color: .green, icon: "arrow.down.left.circle.fill")
                        ledgerSummary(title: "পরে জমা", amount: filteredLaterPayments, color: .green, icon: "banknote.fill")
                        ledgerSummary(title: "মোট বাকি", amount: filteredDue, color: .red, icon: "exclamationmark.circle.fill")
                    }

                    TextField("কাস্টমারের নাম / ফোন খুঁজুন", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal, 1)

                    HStack {
                        Text("কাস্টমার হিসাব").font(.headline)
                        Spacer()
                        Text("\(ledgerRows.count) জন")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    ScrollView(.horizontal, showsIndicators: true) {
                        VStack(spacing: 0) {
                            HStack(spacing: 0) {
                                ledgerCell("তারিখ", width: 92, header: true)
                                ledgerCell("কাস্টমার", width: 130, header: true)
                                ledgerCell("মোট বিক্রি", width: 112, header: true)
                                ledgerCell("অগ্রিম", width: 100, header: true)
                                ledgerCell("পরে জমা", width: 100, header: true)
                                ledgerCell("বাকি", width: 112, header: true)
                            }
                            .background(Color.sysyNavy.opacity(0.10))

                            if ledgerRows.isEmpty {
                                Text(searchText.isEmpty ? "এখনও কোনো কাস্টমার নেই" : "কোনো কাস্টমার পাওয়া যায়নি")
                                    .foregroundStyle(.secondary)
                                    .frame(width: 646, minHeight: 90)
                            } else {
                                ForEach(Array(ledgerRows.enumerated()), id: \.element.id) { index, row in
                                    NavigationLink(destination: CustomerAccountDetailsView(customer: row.customer)) {
                                        HStack(spacing: 0) {
                                            ledgerCell(row.lastDate?.formatted(date: .numeric, time: .omitted) ?? "—", width: 92)
                                            ledgerCell(row.customer.name, width: 130, leading: true)
                                            ledgerCell(formatAmount(row.sales), width: 112)
                                            ledgerCell(formatAmount(row.advance), width: 100, color: .green)
                                            ledgerCell(formatAmount(row.paidLater), width: 100, color: .green)
                                            ledgerCell(formatAmount(row.due), width: 112, color: row.due > 0 ? .red : .green, bold: true)
                                        }
                                        .background(index.isMultiple(of: 2) ? Color(.secondarySystemGroupedBackground) : Color(.systemBackground))
                                        .contentShape(Rectangle())
                                    }
                                    .buttonStyle(.plain)
                                    Divider()
                                }
                            }

                            HStack(spacing: 0) {
                                ledgerCell("মোট", width: 222, header: true, leading: true)
                                ledgerCell(formatAmount(filteredSales), width: 112, header: true)
                                ledgerCell(formatAmount(filteredAdvance), width: 100, header: true)
                                ledgerCell(formatAmount(filteredLaterPayments), width: 100, header: true)
                                ledgerCell(formatAmount(filteredDue), width: 112, header: true, color: .red)
                            }
                            .background(Color.sysyGold.opacity(0.18))
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.separator).opacity(0.65), lineWidth: 1)
                        }
                    }

                    Text("একটি সারিতে চাপ দিলে ওই কাস্টমারের বিস্তারিত হিসাব খুলবে। টেবিলের কলাম দেখতে পাশে সরান।")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Divider()

                    Text("সাম্প্রতিক পেমেন্ট").font(.headline)
                    if store.data.payments.isEmpty {
                        ContentUnavailableView("কোনো পেমেন্ট নেই", systemImage: "banknote", description: Text("পেমেন্ট যোগ হলে এখানে দেখা যাবে।"))
                    } else {
                        ForEach(store.data.payments.sorted(by: { $0.date > $1.date }).prefix(20)) { payment in
                            HStack(spacing: 10) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(payment.customerName).font(.subheadline.bold())
                                    Text(payment.note.isEmpty ? "Payment" : payment.note)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text(payment.date.formatted(date: .abbreviated, time: .omitted))
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text("Rs \(formatAmount(payment.amount))")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(.green)
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("হিসাব")
        }
    }

    private func ledgerSummary(title: String, amount: Double, color: Color, icon: String) -> some View {
        AppCard {
            VStack(alignment: .leading, spacing: 7) {
                Image(systemName: icon).foregroundStyle(color)
                Text(title).font(.caption).foregroundStyle(.secondary)
                Text("Rs \(formatAmount(amount))")
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundStyle(color)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func ledgerCell(_ text: String, width: CGFloat, header: Bool = false, leading: Bool = false, color: Color = .primary, bold: Bool = false) -> some View {
        Text(text)
            .font(.system(size: header ? 12 : 12, weight: header || bold ? .semibold : .regular))
            .foregroundStyle(header ? Color.sysyNavy : color)
            .lineLimit(2)
            .multilineTextAlignment(leading ? .leading : .trailing)
            .frame(width: width, minHeight: 42, alignment: leading ? .leading : .trailing)
            .padding(.horizontal, 7)
            .overlay(alignment: .trailing) {
                Rectangle().fill(Color(.separator).opacity(0.55)).frame(width: 0.5)
            }
    }
}

struct PaymentRow: View {
    let name: String
    let amount: Int
    let date: String
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(name).font(.headline)
                Text(date).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Text("MUR \(formatAmount(amount))")
                .foregroundStyle(.green)
                .bold()
        }
    }
}


struct RateListView: View {
    @EnvironmentObject var store: AppDataStore
    @State private var editing: RateItem?
    @State private var newName = ""
    @State private var newUnit = "Sqft"
    @State private var newRate = ""

    var body: some View {
        List {
            Section("আপনার Rate List") {
                ForEach(store.data.rates) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.name).font(.headline)
                            Text("প্রতি \(item.unit)").font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text("MUR \(formatAmount(item.rate))")
                            .bold()
                            .foregroundStyle(Color.sysyGold)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { editing = item }
                }
                .onDelete { store.data.rates.remove(atOffsets: $0) }
            }

            Section("নতুন Rate যোগ করুন") {
                TextField("যেমন: Sliding Window", text: $newName)
                TextField("Unit: Sqft / Set", text: $newUnit)
                TextField("Rate", text: $newRate)
                    .keyboardType(.decimalPad)

                Button("Rate Save করুন") {
                    guard !newName.trimmingCharacters(in: .whitespaces).isEmpty,
                          let value = Double(newRate) else { return }
                    store.addRate(RateItem(name: newName, unit: newUnit, rate: value))
                    newName = ""
                    newRate = ""
                }
                .disabled(newName.isEmpty || Double(newRate) == nil)
            }
        }
        .navigationTitle("Rate List")
        .sheet(item: $editing) { item in
            EditRateView(store: store, item: item)
        }
    }
}

struct EditRateView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: AppDataStore
    let item: RateItem
    @State private var rateText = ""

    var body: some View {
        NavigationStack {
            Form {
                Text(item.name).font(.headline)
                TextField("Rate", text: $rateText)
                    .keyboardType(.decimalPad)
            }
            .navigationTitle("Rate Edit")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("বাতিল") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let value = Double(rateText),
                           let index = store.data.rates.firstIndex(where: { $0.id == item.id }) {
                            store.data.rates[index].rate = value
                        }
                        dismiss()
                    }
                }
            }
            .onAppear { rateText = String(item.rate) }
        }
    }
}


struct GlobalSearchView: View {
    @EnvironmentObject var store: AppDataStore
    @State private var query = ""

    private var searchText: String { query.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var matchingCustomers: [Customer] {
        guard !searchText.isEmpty else { return [] }
        return store.data.customers.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.phone.localizedCaseInsensitiveContains(searchText) ||
            $0.address.localizedCaseInsensitiveContains(searchText) ||
            $0.projectAddress.localizedCaseInsensitiveContains(searchText)
        }
    }
    private var matchingQuotations: [BusinessQuotation] {
        guard !searchText.isEmpty else { return [] }
        return store.data.quotations.filter {
            $0.number.localizedCaseInsensitiveContains(searchText) ||
            $0.customerName.localizedCaseInsensitiveContains(searchText) ||
            $0.phone.localizedCaseInsensitiveContains(searchText) ||
            $0.projectAddress.localizedCaseInsensitiveContains(searchText)
        }.sorted { $0.createdAt > $1.createdAt }
    }
    private var matchingSites: [String] {
        guard !searchText.isEmpty else { return [] }
        let all = store.data.customers.map(\.projectAddress) + store.data.quotations.map(\.projectAddress)
        return Array(Set(all.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && $0.localizedCaseInsensitiveContains(searchText) })).sorted()
    }
    private var matchingMeasurements: [CustomerMeasurement] {
        guard !searchText.isEmpty else { return [] }
        return store.data.measurements.filter {
            $0.customerName.localizedCaseInsensitiveContains(searchText) ||
            $0.title.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        List {
            if searchText.isEmpty {
                ContentUnavailableView("কী খুঁজবেন লিখুন", systemImage: "magnifyingglass",
                    description: Text("Customer, phone, site name, quotation number বা measurement লিখুন।"))
            } else {
                Section("Customers (\(matchingCustomers.count))") {
                    if matchingCustomers.isEmpty { Text("কোনো customer পাওয়া যায়নি").foregroundStyle(.secondary) }
                    ForEach(matchingCustomers) { customer in
                        NavigationLink(destination: CustomerAccountDetailsView(customer: customer)) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(customer.name).font(.headline)
                                Text("\(customer.phone) • \(customer.address)")
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                Section("Sites (\(matchingSites.count))") {
                    if matchingSites.isEmpty { Text("কোনো site পাওয়া যায়নি").foregroundStyle(.secondary) }
                    ForEach(matchingSites, id: \.self) { site in
                        Label(site, systemImage: "mappin.and.ellipse")
                    }
                }
                Section("Quotations (\(matchingQuotations.count))") {
                    if matchingQuotations.isEmpty { Text("কোনো quotation পাওয়া যায়নি").foregroundStyle(.secondary) }
                    ForEach(matchingQuotations) { quotation in
                        NavigationLink(destination: QuotationPreviewView(quotation: quotation)) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(quotation.number).font(.headline)
                                Text(quotation.customerName).font(.subheadline)
                                Text("MUR \(formatAmount(quotation.grandTotal)) • \(quotation.status.banglaTitle)")
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                Section("Measurements (\(matchingMeasurements.count))") {
                    if matchingMeasurements.isEmpty { Text("কোনো measurement পাওয়া যায়নি").foregroundStyle(.secondary) }
                    ForEach(matchingMeasurements) { item in
                        VStack(alignment: .leading, spacing: 3) {
                            Text(item.title).font(.headline)
                            Text(item.customerName).font(.caption)
                            Text("\(String(format: "%.2f", item.width)) × \(String(format: "%.2f", item.height)) × \(item.quantity) = MUR \(formatAmount(item.amount))")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .searchable(text: $query, prompt: "নাম / ফোন / Site / Quotation খুঁজুন")
        .navigationTitle("সব তথ্য Search")
    }
}

struct SiteListView: View {
    @EnvironmentObject var store: AppDataStore
    @State private var query = ""

    private var sites: [String] {
        let all = store.data.customers.map(\.projectAddress) + store.data.quotations.map(\.projectAddress)
        return Array(Set(all.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && (query.isEmpty || $0.localizedCaseInsensitiveContains(query)) })).sorted()
    }

    var body: some View {
        List {
            if sites.isEmpty {
                ContentUnavailableView("কোনো Site নেই", systemImage: "mappin.and.ellipse",
                    description: Text("Customer Edit বা Quotation-এ Project / Site Address যোগ করলে এখানে দেখা যাবে।"))
            } else {
                ForEach(sites, id: \.self) { site in
                    let customers = store.data.customers.filter { $0.projectAddress.caseInsensitiveCompare(site) == .orderedSame }
                    let quotations = store.data.quotations.filter { $0.projectAddress.caseInsensitiveCompare(site) == .orderedSame }
                    VStack(alignment: .leading, spacing: 5) {
                        Text(site).font(.headline)
                        Text("Customers: \(customers.count) • Quotations: \(quotations.count)")
                            .font(.caption).foregroundStyle(.secondary)
                        if !customers.isEmpty {
                            Text(customers.map(\.name).joined(separator: ", "))
                                .font(.caption)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .searchable(text: $query, prompt: "Site name খুঁজুন")
        .navigationTitle("সব কাজের Site")
    }
}

struct SettingsView: View {
    @AppStorage("SYSY_FAMILY_LANGUAGE") private var selectedLanguage = "bn"

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        ProfileAvatar(size: 64)
                        VStack(alignment: .leading) {
                            Text("Sobunkur Sotrothdar").font(.headline)
                            Text("SYSY FAMILY").font(.subheadline)
                        }
                    }
                    .padding(.vertical, 6)
                }
                Section("Business") {
                    NavigationLink(destination: GlobalSearchView()) {
                        Label("সব তথ্য Search করুন", systemImage: "magnifyingglass")
                    }
                    NavigationLink(destination: SiteListView()) {
                        Label("সব কাজের Site এক জায়গায়", systemImage: "mappin.and.ellipse")
                    }
                    NavigationLink(destination: RateListView()) {
                        Label("Rate List — নিজে Edit করুন", systemImage: "list.number")
                    }
                    Label("ব্যবসার তথ্য", systemImage: "building.2")
                    Label("Profile & Branding", systemImage: "person.crop.circle")
                    NavigationLink(destination: PaymentTrackingView()) {
                        Label("Payment Tracking", systemImage: "creditcard")
                    }
                    NavigationLink(destination: DataStorageView()) {
                        Label("Data Storage", systemImage: "externaldrive")
                    }
                    NavigationLink(destination: BackupView()) {
                        Label("ডাটা Backup", systemImage: "icloud")
                    }
                    Picker(selection: $selectedLanguage) {
                        Text("বাংলা").tag("bn")
                        Text("English").tag("en")
                    } label: {
                        Label("ভাষা / Language", systemImage: "globe")
                    }
                }
                Section {
                    Label("সাহায্য ও সাপোর্ট", systemImage: "questionmark.circle")
                    Label("অ্যাপ সম্পর্কে", systemImage: "info.circle")
                }
            }
            .navigationTitle(selectedLanguage == "en" ? "More" : "আরও")
        }
        .environment(\.locale, Locale(identifier: selectedLanguage))
    }
}
