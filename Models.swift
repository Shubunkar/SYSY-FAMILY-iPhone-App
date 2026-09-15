import Foundation
import SwiftUI
import CryptoKit

struct Customer: Identifiable, Codable {
    var projectAddress: String = ""
    var siteNote: String = ""
    var photoFileNames: [String] = []
    let id = UUID()
    var name: String
    var phone: String
    var address: String
}

struct QuoteItem: Identifiable, Codable {
    let id = UUID()
    var title: String
    var width: Double
    var height: Double
    var quantity: Int
    var rate: Double

    var sqft: Double { (width * height) * Double(quantity) }
    var amount: Double { sqft * rate }
}

struct Quote: Identifiable, Codable {
    let id = UUID()
    var number: String
    var customer: Customer
    var items: [QuoteItem]
    var advance: Double

    var subtotal: Double { items.reduce(0) { $0 + $1.amount } }
    var balance: Double { max(0, subtotal - advance) }
}



struct BackupData: Codable {
    var exportedAt: Date
    var appName: String
    var version: String
    var appData: PersistedAppData
    /// SHA-256 of the encoded appData. Optional for backward compatibility with older backups.
    var checksum: String?

    init(exportedAt: Date, appName: String, version: String, appData: PersistedAppData) {
        self.exportedAt = exportedAt
        self.appName = appName
        self.version = version
        self.appData = appData
        self.checksum = BackupData.makeChecksum(for: appData)
    }

    static func makeChecksum(for appData: PersistedAppData) -> String? {
        guard let data = try? JSONEncoder().encode(appData) else { return nil }
        return SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    var hasValidChecksum: Bool {
        guard let checksum else { return true }
        return checksum == Self.makeChecksum(for: appData)
    }

    /// V36 restore gate: validates metadata and the complete data graph before replacement.
    var restoreValidationMessage: String? {
        guard appName == "SYSY FAMILY" else { return "এই backup SYSY FAMILY app-এর নয়" }
        guard !version.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return "Backup version পাওয়া যায়নি" }
        guard exportedAt.timeIntervalSince1970 > 0, exportedAt <= Date().addingTimeInterval(300) else { return "Backup-এর তারিখ/সময় সঠিক নয়" }
        guard hasValidChecksum else { return "Backup checksum মেলেনি—ফাইলটি পরিবর্তিত বা corrupt হতে পারে" }
        guard appData.isValidForRestore else { return "Backup data-তে অবৈধ amount/rate/measurement পাওয়া গেছে" }
        return nil
    }
}

struct RateItem: Identifiable, Codable {
    let id = UUID()
    var name: String
    var unit: String
    var rate: Double
}

final class RateStore: ObservableObject {
    @Published var rates: [RateItem] = [
        RateItem(name: "Aluminium Profile", unit: "Sqft", rate: 0),
        RateItem(name: "Glass", unit: "Sqft", rate: 0),
        RateItem(name: "Hardware", unit: "Set", rate: 0),
        RateItem(name: "Labour", unit: "Sqft", rate: 0)
    ]
}


struct Measurement: Identifiable, Codable {
    let id = UUID()
    var title: String
    var width: Double
    var height: Double
    var quantity: Int
    var rate: Double

    var sqft: Double {
        width * height * Double(quantity)
    }

    var total: Double {
        sqft * rate
    }
}


struct QuotationLine: Identifiable, Codable {
    let id = UUID()
    var title: String
    var description: String
    var amount: Double
}

enum QuotationStatus: String, Codable, CaseIterable, Identifiable {
    case draft = "Draft"
    case sent = "Sent"
    case confirmed = "Confirmed"
    case production = "Production"
    case installed = "Installed"
    case completed = "Completed"

    var id: String { rawValue }

    var uiColor: Color {
        switch self {
        case .draft: return .gray
        case .sent: return .blue
        case .confirmed: return .green
        case .production: return .orange
        case .installed: return .purple
        case .completed: return .teal
        }
    }

    var banglaTitle: String {
        switch self {
        case .draft: return "খসড়া"
        case .sent: return "পাঠানো হয়েছে"
        case .confirmed: return "নিশ্চিত"
        case .production: return "তৈরি হচ্ছে"
        case .installed: return "ইনস্টল"
        case .completed: return "পূরণ"
        }
    }
}

struct BusinessQuotation: Identifiable, Codable {
    let id: UUID
    var number: String
    var customerName: String
    var phone: String
    var projectAddress: String
    var siteNote: String
    var status: QuotationStatus
    var lines: [QuotationLine]
    var discount: Double
    var advance: Double
    /// Persisted creation date used for accurate monthly reporting and PDF dates.
    var createdAt: Date
    /// Date when the current quotation advance was recorded. Optional for backward compatibility.
    var advanceDate: Date?

    init(
        id: UUID = UUID(),
        number: String,
        customerName: String,
        phone: String,
        projectAddress: String = "",
        siteNote: String = "",
        status: QuotationStatus = .draft,
        lines: [QuotationLine],
        discount: Double,
        advance: Double,
        createdAt: Date = Date(),
        advanceDate: Date? = nil
    ) {
        self.id = id
        self.number = number
        self.customerName = customerName
        self.phone = phone
        self.projectAddress = projectAddress
        self.siteNote = siteNote
        self.status = status
        self.lines = lines
        self.discount = max(0, discount)
        self.advance = max(0, advance)
        self.createdAt = createdAt
        self.advanceDate = advanceDate ?? (advance > 0 ? createdAt : nil)
    }

    var subtotal: Double { lines.reduce(0) { $0 + $1.amount } }
    var grandTotal: Double { max(0, subtotal - discount) }
    var balance: Double { max(0, grandTotal - advance) }
    var appliedAdvance: Double { min(advance, grandTotal) }

    private enum CodingKeys: String, CodingKey {
        case id, number, customerName, phone, projectAddress, siteNote, status, lines, discount, advance, createdAt, advanceDate
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        number = try container.decode(String.self, forKey: .number)
        customerName = try container.decode(String.self, forKey: .customerName)
        phone = try container.decode(String.self, forKey: .phone)
        projectAddress = try container.decodeIfPresent(String.self, forKey: .projectAddress) ?? ""
        siteNote = try container.decodeIfPresent(String.self, forKey: .siteNote) ?? ""
        status = try container.decodeIfPresent(QuotationStatus.self, forKey: .status) ?? .draft
        lines = try container.decode([QuotationLine].self, forKey: .lines)
        discount = max(0, try container.decode(Double.self, forKey: .discount))
        advance = max(0, try container.decode(Double.self, forKey: .advance))
        // Backward compatible with older backups that had no quotation date or advance date.
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        advanceDate = try container.decodeIfPresent(Date.self, forKey: .advanceDate) ?? (advance > 0 ? createdAt : nil)
    }
}


struct PaymentRecord: Identifiable, Codable {
    let id = UUID()
    var customerName: String
    var amount: Double
    var date: Date
    var note: String
}

struct CustomerAccount: Identifiable, Codable {
    let id = UUID()
    var customer: Customer
    var quotations: [BusinessQuotation]
    var payments: [PaymentRecord]

    var totalQuoted: Double { quotations.reduce(0) { $0 + $1.grandTotal } }
    var quotationAdvances: Double { quotations.reduce(0) { $0 + $1.appliedAdvance } }
    var paymentRecordsTotal: Double { payments.reduce(0) { $0 + $1.amount } }
    var totalPaid: Double { quotationAdvances + paymentRecordsTotal }
    var totalDue: Double { max(0, totalQuoted - totalPaid) }
}


final class BusinessStore: ObservableObject {
    @Published var customers: [Customer] = []
    @Published var quotations: [BusinessQuotation] = []
    @Published var payments: [PaymentRecord] = []

    var totalSales: Double {
        quotations.reduce(0) { $0 + $1.grandTotal }
    }

    var totalAdvanceCollected: Double {
        quotations.reduce(0) { $0 + $1.appliedAdvance }
    }

    var totalCollected: Double {
        totalAdvanceCollected + payments.reduce(0) { $0 + $1.amount }
    }

    var totalDue: Double {
        max(0, totalSales - totalCollected)
    }

    var monthlySales: Double {
        let calendar = Calendar.current
        let now = Date()
        return quotations
            .filter { calendar.isDate($0.createdAt, equalTo: now, toGranularity: .month) }
            .reduce(0) { $0 + $1.grandTotal }
    }

    /// Collection for the current month includes both quotation advances and
    /// separately recorded payments. Advances use their persisted advance date;
    /// older data falls back to the quotation creation date for compatibility.
    var monthlyCollection: Double {
        let calendar = Calendar.current
        let now = Date()
        let monthlyAdvances = quotations
            .filter { calendar.isDate($0.advanceDate ?? $0.createdAt, equalTo: now, toGranularity: .month) }
            .reduce(0) { $0 + $1.appliedAdvance }
        let monthlyPayments = payments
            .filter { calendar.isDate($0.date, equalTo: now, toGranularity: .month) }
            .reduce(0) { $0 + $1.amount }
        return monthlyAdvances + monthlyPayments
    }
}


extension PersistedAppData {
    /// Reject obviously corrupt backup values before replacing the current local data.
    var isValidForRestore: Bool {
        customers.allSatisfy { $0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false && $0.phone.isEmpty == false }
        && quotations.allSatisfy {
            $0.discount >= 0 && $0.advance >= 0
            && $0.lines.allSatisfy { $0.amount >= 0 }
            && $0.lines.allSatisfy { $0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false }
        }
        && payments.allSatisfy { $0.amount >= 0 }
        && rates.allSatisfy { $0.rate >= 0 }
        && measurements.allSatisfy { $0.rate >= 0 && $0.width > 0 && $0.height > 0 && $0.quantity > 0 }
    }
}

struct PersistedAppData: Codable {
    var customers: [Customer]
    var quotations: [BusinessQuotation]
    var payments: [PaymentRecord]
    var rates: [RateItem]
    var measurements: [CustomerMeasurement]
}

final class AppDataStore: ObservableObject {
    @Published var data: PersistedAppData {
        didSet { save() }
    }

    private let key = "SYSY_FAMILY_APP_DATA"

    init() {
        if let saved = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode(PersistedAppData.self, from: saved) {
            data = decoded
        } else {
            data = PersistedAppData(customers: [], quotations: [], payments: [], rates: [], measurements: [])
        }
    }

    private func save() {
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    func clearAll() {
        data = PersistedAppData(customers: [], quotations: [], payments: [], rates: [], measurements: [])
    }

    // V62: keep one local rollback snapshot before a backup restore.
    private let preRestoreKey = "SYSY_FAMILY_PRE_RESTORE_DATA"

    func restore(_ restoredData: PersistedAppData) {
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: preRestoreKey)
        }
        data = restoredData
    }

    var canUndoLastRestore: Bool {
        UserDefaults.standard.data(forKey: preRestoreKey) != nil
    }

    @discardableResult
    func undoLastRestore() -> Bool {
        guard let encoded = UserDefaults.standard.data(forKey: preRestoreKey),
              let previous = try? JSONDecoder().decode(PersistedAppData.self, from: encoded) else {
            return false
        }
        // Keep the current data as the next rollback point.
        if let currentEncoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(currentEncoded, forKey: preRestoreKey)
        }
        data = previous
        return true
    }

    /// Returns a readable, date-based quotation number and continues the sequence for the current day.
    /// Creates a new quotation from an existing one without copying its status or payment progress.
    /// The duplicate starts as Draft with a fresh quotation number and zero advance.
    func duplicateQuotation(_ quotation: BusinessQuotation) {
        let copy = BusinessQuotation(
            number: nextQuotationNumber(),
            customerName: quotation.customerName,
            phone: quotation.phone,
            projectAddress: quotation.projectAddress,
            siteNote: quotation.siteNote,
            status: .draft,
            lines: quotation.lines.map { QuotationLine(title: $0.title, description: $0.description, amount: $0.amount) },
            discount: quotation.discount,
            advance: 0,
            advanceDate: nil
        )
        data.quotations.insert(copy, at: 0)
    }

    func nextQuotationNumber(for date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyyMMdd"
        let prefix = "QT-\(formatter.string(from: date))-"
        let count = data.quotations.filter { $0.number.hasPrefix(prefix) }.count
        return String(format: "QT-%@-%03d", formatter.string(from: date), count + 1)
    }
}


extension AppDataStore {
    var totalSales: Double {
        data.quotations.reduce(0) { $0 + $1.grandTotal }
    }

    var totalAdvanceCollected: Double {
        data.quotations.reduce(0) { $0 + $1.appliedAdvance }
    }

    var totalCollected: Double {
        totalAdvanceCollected + data.payments.reduce(0) { $0 + $1.amount }
    }

    var totalDue: Double {
        max(0, totalSales - totalCollected)
    }

    var monthlySales: Double {
        let calendar = Calendar.current
        let now = Date()
        return data.quotations
            .filter { calendar.isDate($0.createdAt, equalTo: now, toGranularity: .month) }
            .reduce(0) { $0 + $1.grandTotal }
    }

    /// Current-month collection combines quotation advances and recorded payments.
    /// Advances use their persisted advance date; older backups fall back to createdAt.
    var monthlyCollection: Double {
        let calendar = Calendar.current
        let now = Date()
        let monthlyAdvances = data.quotations
            .filter { calendar.isDate($0.advanceDate ?? $0.createdAt, equalTo: now, toGranularity: .month) }
            .reduce(0) { $0 + $1.appliedAdvance }
        let monthlyPayments = data.payments
            .filter { calendar.isDate($0.date, equalTo: now, toGranularity: .month) }
            .reduce(0) { $0 + $1.amount }
        return monthlyAdvances + monthlyPayments
    }
}


struct CustomerMeasurement: Identifiable, Codable {
    let id = UUID()
    var customerName: String
    var title: String
    var width: Double
    var height: Double
    var quantity: Int
    var rate: Double

    var sqft: Double { width * height * Double(quantity) }
    var amount: Double { sqft * rate }
}
