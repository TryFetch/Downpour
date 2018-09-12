#if swift(>=4.2)
#else
protocol CaseIterable {
    static var allCases: [Self] { get }
}
#endif
