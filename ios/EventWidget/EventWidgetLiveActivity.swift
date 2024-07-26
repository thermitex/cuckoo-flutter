//
//  EventWidgetLiveActivity.swift
//  EventWidget
//
//  Created by Ruijie Li on 23/7/2024.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct LiveActivitiesAppAttributes: ActivityAttributes, Identifiable {
  public typealias LiveDeliveryData = ContentState

  public struct ContentState: Codable, Hashable { }

  var id = UUID()
}

let sharedDefault = UserDefaults(suiteName: "group.jerry.li.Cuckoo")!
let primaryColor = hexStringToColor(hex: "586CF5")

@available(iOSApplicationExtension 16.1, *)
struct CuckooEventLiveActivity: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: LiveActivitiesAppAttributes.self) { context in
      
      // Read configurations passed from Flutter side
      let eventId = sharedDefault.string(forKey: context.attributes.prefixedKey("eventId"))!
      let courseCode = sharedDefault.string(forKey: context.attributes.prefixedKey("courseCode"))!
      let courseColorHex = sharedDefault.string(forKey: context.attributes.prefixedKey("courseColorHex"))!
      let eventTitle = sharedDefault.string(forKey: context.attributes.prefixedKey("eventTitle"))!
      let eventDueDate = Date(timeIntervalSince1970: sharedDefault.double(forKey: context.attributes.prefixedKey("eventDueDate")))
      let currentDate = Date(timeIntervalSince1970: sharedDefault.double(forKey: context.attributes.prefixedKey("currentDate")))
      
      // Derive variables
      let courseColor = hexStringToColor(hex: courseColorHex)
      let timeRemaining = currentDate...eventDueDate
      let dueFormatter = DateFormatter()
      dueFormatter.dateFormat = "HH:mm MMM d"
      
      return ZStack() {
        LinearGradient(stops: [
          .init(color: .clear, location: 0.55),
          .init(color: courseColor.opacity(courseCode.count > 0 ? 0.24 : 0.0), location: 1.0)
        ], startPoint: .topLeading, endPoint: .bottomTrailing)
        VStack(alignment: .leading, spacing: 0) {
          HStack(spacing: 5.0) {
            if (courseCode.count > 0) {
              Text(courseCode)
                .font(.system(size: 13.0, weight: .bold))
                .foregroundStyle(courseColor)
            }
            Text(eventTitle)
              .font(.system(size: 13.0))
              .lineLimit(1)
          }
          .padding(.bottom, 2.0)
          HStack() {
            VStack(alignment: .leading) {
              Text(timerInterval: timeRemaining, countsDown: true, showsHours: true)
                .font(.custom("Montserrat-Bold", size: 37.0))
              Text("Til due at \(Text(dueFormatter.string(from: eventDueDate)).foregroundStyle(primaryColor))")
                .font(.system(size: 13.0, weight: .medium))
            }
            Spacer()
            Link(destination: URL(string: "cuckoo://action?name=complete&id=\(eventId)")!) {
              Image(systemName: "checkmark.circle.fill")
                  .resizable()
                  .scaledToFit()
                  .frame(width: 42.0, height: 42.0)
                  .foregroundStyle(primaryColor)
                  .padding(.top, 4.0)
            }
          }
        }
        .padding(.vertical, 18.0)
        .padding(.horizontal, 25.0)
      }
      
    } dynamicIsland: { context in
      
      // Read configurations passed from Flutter side
      let eventId = sharedDefault.string(forKey: context.attributes.prefixedKey("eventId"))!
      let courseCode = sharedDefault.string(forKey: context.attributes.prefixedKey("courseCode"))!
      let courseColorHex = sharedDefault.string(forKey: context.attributes.prefixedKey("courseColorHex"))!
      let eventTitle = sharedDefault.string(forKey: context.attributes.prefixedKey("eventTitle"))!
      
      let eventDueEpoch = sharedDefault.double(forKey: context.attributes.prefixedKey("eventDueDate"))
      let currentEpoch = sharedDefault.double(forKey: context.attributes.prefixedKey("currentDate"))
      let eventDueDate = Date(timeIntervalSince1970: eventDueEpoch)
      let currentDate = Date(timeIntervalSince1970: currentEpoch)
      
      // Derive variables
      let courseColor = hexStringToColor(hex: courseColorHex)
      let timeRemaining = currentDate...eventDueDate
      
      let daysRemaining = Int(eventDueEpoch - currentEpoch) / 86400
      let hoursRemaining = (Int(eventDueEpoch - currentEpoch) - daysRemaining * 86400) / 3600
      
      let dueFormatter = DateFormatter()
      dueFormatter.dateFormat = "HH:mm MMM d"
      
      return DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          Image("AppBanner")
            .padding(.leading, 12.0)
        }
        DynamicIslandExpandedRegion(.bottom) {
          VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 5.0) {
              if (courseCode.count > 0) {
                Text(courseCode)
                  .font(.system(size: 13.0, weight: .bold))
                  .foregroundStyle(courseColor)
              }
              Text(eventTitle)
                .font(.system(size: 13.0))
                .lineLimit(1)
            }
            .padding(.bottom, 3.0)
            HStack() {
              VStack(alignment: .leading) {
                Text(timerInterval: timeRemaining, countsDown: true, showsHours: true)
                  .font(.custom("Montserrat-Bold", size: 37.0))
                Text("Til due at \(Text(dueFormatter.string(from: eventDueDate)).foregroundStyle(primaryColor))")
                  .font(.system(size: 13.0, weight: .medium))
              }
              Spacer()
              Link(destination: URL(string: "cuckoo://action?name=complete&id=\(eventId)")!) {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 42.0, height: 42.0)
                    .foregroundStyle(primaryColor)
                    .padding(.top, 4.0)
              }
            }
          }
          .padding(.horizontal, 12.0)
          .padding(.bottom, 3.0)
        }
      } compactLeading: {
        Image("MinimalIcon")
          .resizable()
          .scaledToFit()
          .padding(.leading, 3.0)
      } compactTrailing: {
        Text("\(daysRemaining > 0 ? "\(daysRemaining)d " : "")\(hoursRemaining)h")
          .foregroundStyle(primaryColor)
          .padding(.trailing, 4.0)
      } minimal: {
        Image("MinimalIcon")
          .resizable()
          .scaledToFit()
      }
    }
  }
}


extension LiveActivitiesAppAttributes {
  func prefixedKey(_ key: String) -> String {
    return "\(id)_\(key)"
  }
}
