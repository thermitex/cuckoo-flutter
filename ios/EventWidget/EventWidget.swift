//
//  EventWidget.swift
//  EventWidget
//
//  Created by Ruijie Li on 23/7/2024.
//

import WidgetKit
import SwiftUI

private let widgetGroupId = "group.jerry.li.Cuckoo"

struct Provider: TimelineProvider {
  func placeholder(in context: Context) -> DateEntry {
    DateEntry(date: Date())
  }

  func getSnapshot(in context: Context, completion: @escaping (DateEntry) -> ()) {
    let entry = DateEntry(date: Date())
    completion(entry)
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
    let date = Date()
    let entry = DateEntry(date: date)

    let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 30, to: date)!

    let timeline = Timeline(
        entries:[entry],
        policy: .after(nextUpdateDate)
    )

    completion(timeline)
  }
}

struct DateEntry: TimelineEntry {
  let date: Date
}

struct EventWidgetEntryView : View {
  var entry: Provider.Entry
  let data = UserDefaults.init(suiteName: widgetGroupId)
  @Environment(\.widgetFamily) var family
  
  var hasEvent = false
  var remainingDay: Int?
  var remainingHour: Int?
  var dueDateStr: String?
  var courseCode: String?
  var eventTitle: String?
  var color: Color?
  
  init(entry: Provider.Entry) {
    self.entry = entry
    
    // Check data availability first
    hasEvent = data?.bool(forKey: "hasEvent") ?? false
    if (hasEvent) {
      courseCode = data!.string(forKey: "courseCode")
      eventTitle = data!.string(forKey: "eventTitle")
      
      color = hexStringToColor(hex: data!.string(forKey: "courseColorHex")!)
      if (courseCode?.count == 0) {
        color = .gray
      }
      
      let dueDate = Date(timeIntervalSince1970: data!.double(forKey: "eventDueDate"))
      let dueFormatter = DateFormatter()
      dueFormatter.dateFormat = "HH:mm MMM d"
      dueDateStr = dueFormatter.string(from: dueDate)
      
      let remainingSecs = max(Int(dueDate.timeIntervalSince1970 - entry.date.timeIntervalSince1970), 0)
      remainingDay = remainingSecs / 86400
      remainingHour = (remainingSecs - remainingDay! * 86400) / 3600
    }
  }

  var body: some View {
    if (hasEvent) {
      if (family == .systemSmall) {
        HStack {
          VStack (alignment: .leading) {
            Text("\(Text(String(remainingDay!)).font(.custom("Montserrat-Bold", size: 31.0)))d \(Text(String(remainingHour!)).font(.custom("Montserrat-Bold", size: 31.0)))hr")
              .font(.custom("Montserrat-Medium", size: 15.0))
            Spacer()
            (Text(courseCode!)
              .bold()
              .foregroundColor(color!)
              .font(.caption) +
             Text("\n") +
             Text(eventTitle!))
            .font(.subheadline)
            .lineLimit(3)
            Spacer()
              .frame(height: 5)
            Text(dueDateStr!)
              .bold()
              .font(.caption2)
              .foregroundColor(color!)
          }
          Spacer()
        }
      } else if (family == .systemMedium) {
        HStack {
          VStack(alignment: .leading) {
            Image("AppBanner")
            Spacer()
            (Text(courseCode!)
              .bold()
              .foregroundColor(color!)
              .font(.caption) +
             Text("\n") +
             Text(eventTitle!))
            .font(.subheadline)
            .lineLimit(4)
            Spacer()
              .frame(height: 5)
            Text(dueDateStr!)
              .bold()
              .font(.caption2)
              .foregroundColor(color!)
          }
          Spacer(minLength: 30.0)
          VStack(alignment: .trailing) {
            Spacer()
            Text("\(Text(String(remainingDay!)).font(.custom("Montserrat-Bold", size: 42.0)))d")
              .font(.custom("Montserrat-Medium", size: 20.0))
              .frame(height: -3.0)
            Text("\(Text(String(remainingHour!)).font(.custom("Montserrat-Bold", size: 42.0)))h")
              .font(.custom("Montserrat-Medium", size: 20.0))
            Text("Time\nRemaining")
              .foregroundColor(Color(.secondaryLabel))
              .font(.caption2)
              .multilineTextAlignment(.trailing)
          }
        }
      } else if (family == .accessoryInline) {
        Text("\(remainingDay! > 0 ? "\(remainingDay!)d " : "")\(remainingHour!)h Left")
          .padding(.leading, 2.0)
      } else if (family == .accessoryRectangular) {
        HStack(spacing: 8.0) {
          RoundedRectangle(cornerRadius: 3.0)
            .fill()
            .frame(width: 6.0, height: .infinity)
            .padding(.vertical, 2.0)
          VStack(alignment: .leading) {
            (Text(courseCode!)
              .bold()
              .font(.caption) +
             Text(courseCode!.count > 0 ? "\n" : "") +
             Text(eventTitle!)
              .fontWeight(.medium))
            .font(.subheadline)
            .lineLimit(2)
            Spacer()
              .frame(height: 5)
            Text(dueDateStr!)
              .bold()
              .font(.caption2)
          }
          Spacer()
        }
      }
    } else {
      Text("No Events")
        .foregroundColor(Color(.secondaryLabel))
    }
  }
}

struct CuckooUpcomingEventWidget: Widget {
  let kind: String = "CuckooUpcomingEventWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: Provider()) { entry in
      if #available(iOS 17.0, *) {
        EventWidgetEntryView(entry: entry)
          .containerBackground(.fill.tertiary, for: .widget)
      } else {
        EventWidgetEntryView(entry: entry)
          .padding()
          .background()
      }
    }
    .supportedFamilies([.systemSmall, .systemMedium, .accessoryInline, .accessoryRectangular])
    .configurationDisplayName("Upcoming Event")
    .description("Display the next upcoming event in the events list.")
  }
}
