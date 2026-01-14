
//
//  CalendarPopupView.swift
//  CakeShop.2.1
//
//  Created by Asadbek Muzaffarov on 28/11/25.
//

import UIKit

final class CalendarPopupView: UIView {

    // MARK: - UI
    private let contentView = UIView()
    private let monthLabel = UILabel()
    private let prevButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)
    private let weekdayStack = UIStackView()
    private let daysStack = UIStackView()

    // MARK: - State
    var onDateSelected: ((Date) -> Void)?
    private var selectedDate: Date?
    private var currentMonth = Date()

    private let today = Calendar.current.startOfDay(for: Date())

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false

        backgroundColor = UIColor.black.withAlphaComponent(0.3)

        let tapOutside = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        tapOutside.cancelsTouchesInView = false
        addGestureRecognizer(tapOutside)

        setupContent()
        setupWeekdays()
        showCalendar(for: currentMonth)
    }

    required init?(coder: NSCoder) { fatalError() }


    // MARK: - Dismiss Logic

    @objc private func backgroundTapped(_ sender: UITapGestureRecognizer) {
        let point = sender.location(in: self)
        if !contentView.frame.contains(point) {
            dismiss()
        }
    }

    private func dismiss() {
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0
        }) { _ in
            self.removeFromSuperview()
        }
    }


    // MARK: - UI Layout

    private func setupContent() {
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 22
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)

        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            contentView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -40),
            contentView.heightAnchor.constraint(equalToConstant: 430)
        ])

        // HEADER
        monthLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        monthLabel.textAlignment = .center

        prevButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        nextButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)

        prevButton.addTarget(self, action: #selector(prevMonth), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextMonth), for: .touchUpInside)

        let header = UIStackView(arrangedSubviews: [prevButton, monthLabel, nextButton])
        header.axis = .horizontal
        header.distribution = .equalCentering
        header.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(header)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            header.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            header.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            header.heightAnchor.constraint(equalToConstant: 30)
        ])

        // WEEKDAYS STACK
        weekdayStack.axis = .horizontal
        weekdayStack.distribution = .fillEqually
        weekdayStack.spacing = 8
        weekdayStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(weekdayStack)

        NSLayoutConstraint.activate([
            weekdayStack.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 12),
            weekdayStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            weekdayStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            weekdayStack.heightAnchor.constraint(equalToConstant: 22)
        ])

        // DAYS GRID
        daysStack.axis = .vertical
        daysStack.spacing = 12
        daysStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(daysStack)

        NSLayoutConstraint.activate([
            daysStack.topAnchor.constraint(equalTo: weekdayStack.bottomAnchor, constant: 12),
            daysStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            daysStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),

            // IMPORTANT FIX → prevents last row from stretching big
            daysStack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -20)
        ])
    }


    // MARK: - Weekdays ("Mon Tue Wed…")

    private func setupWeekdays() {
        let symbols = Calendar.current.shortWeekdaySymbols
        let first = Calendar.current.firstWeekday // usually Sunday=1

        let ordered = Array(symbols[(first - 1)...]) + Array(symbols[..<(first - 1)])

        for s in ordered {
            let lbl = UILabel()
            lbl.text = s.uppercased()
            lbl.font = .systemFont(ofSize: 12, weight: .semibold)
            lbl.textColor = .gray
            lbl.textAlignment = .center
            weekdayStack.addArrangedSubview(lbl)
        }
    }


    // MARK: - Calendar Rendering

    private func showCalendar(for date: Date) {
        currentMonth = date

        let fmt = DateFormatter()
        fmt.dateFormat = "LLLL yyyy"
        monthLabel.text = fmt.string(from: date)

        daysStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let cal = Calendar.current
        let range = cal.range(of: .day, in: .month, for: date)!
        let comps = cal.dateComponents([.year, .month], from: date)
        let firstDay = cal.date(from: comps)!
        let adjustedFirst = adjustedWeekday(cal.component(.weekday, from: firstDay))

        var row = createNewRow()

        // Empty placeholders
        for _ in 1..<adjustedFirst {
            row.addArrangedSubview(makeEmptyDay())
        }

        // All days
        for day in range {
            if row.arrangedSubviews.count == 7 {
                daysStack.addArrangedSubview(row)
                row = createNewRow()
            }

            let dayDate = cal.date(from: DateComponents(year: comps.year, month: comps.month, day: day))!
            let btn = makeDayButton(day: day, date: dayDate)

            row.addArrangedSubview(btn)
        }

        daysStack.addArrangedSubview(row)
    }


    // MARK: - Rows & Empty Cells

    private func createNewRow() -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.distribution = .fillEqually
        row.spacing = 8
        return row
    }

    private func makeEmptyDay() -> UIView {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return v
    }

    private func adjustedWeekday(_ w: Int) -> Int {
        return (w == 1) ? 7 : w - 1  // shift Sunday to end
    }


    // MARK: - Day Button (Square Cells)

    private func makeDayButton(day: Int, date: Date) -> UIButton {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false

        // Perfect square calculation
        let totalSpacing: CGFloat = 8 * 6 // 6 gaps between 7 items

        let contentWidth =
            UIScreen.main.bounds.width -
            16 - 16 - // contentView left/right
            12 - 12   // daysStack left/right

        let size = (contentWidth - totalSpacing) / 7

        btn.widthAnchor.constraint(equalToConstant: size).isActive = true
        btn.heightAnchor.constraint(equalToConstant: size).isActive = true

        // Appearance
        btn.setTitle("\(day)", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 15)
        btn.layer.cornerRadius = 10
        btn.backgroundColor = UIColor(white: 0.95, alpha: 1)
        btn.tag = day

        // Behavior
        let isPast = date < today
        let isToday = Calendar.current.isDate(date, inSameDayAs: today)

        if isPast {
            btn.isEnabled = false
            btn.setTitleColor(.lightGray, for: .normal)
            return btn
        }

        // Today highlight (default if no selection yet)
        if isToday && selectedDate == nil {
            btn.layer.borderWidth = 2
            btn.layer.borderColor = UIColor.systemBlue.cgColor
            btn.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        }

        // Selected
        if let sel = selectedDate,
           Calendar.current.isDate(sel, inSameDayAs: date) {
            btn.backgroundColor = UIColor(red: 0.95, green: 0.22, blue: 0.56, alpha: 1)
            btn.setTitleColor(.white, for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        } else {
            btn.setTitleColor(.systemBlue, for: .normal)
        }

        btn.addTarget(self, action: #selector(dayTapped(_:)), for: .touchUpInside)
        return btn
    }


    // MARK: - Actions

    @objc private func prevMonth() {
        if let new = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) {
            showCalendar(for: new)
        }
    }

    @objc private func nextMonth() {
        if let new = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) {
            showCalendar(for: new)
        }
    }

    @objc private func dayTapped(_ sender: UIButton) {
        let cal = Calendar.current
        var comps = cal.dateComponents([.year, .month], from: currentMonth)
        comps.day = sender.tag

        let date = cal.date(from: comps)!
        selectedDate = date

        onDateSelected?(date)
        showCalendar(for: currentMonth)
        dismiss()
    }
}
