//
//  ViewController.swift
//  CalDesktopSync
//
//  Created by Alexander Marquardt on 19.11.18.
//  Copyright © 2018 Alexander Marquardt. All rights reserved.
//

import Cocoa
import EventKit

class ViewController: NSViewController {

	let sourcename = "Kalendar"
	let destname = "Arbeit"
	var events: [EKEvent] = []
	var calendarItem: [EKCalendarItem] = []
	var dCalendar = EKCalendar()
	var sCalendar = EKCalendar()
	
	override func viewDidLoad() {
		super.viewDidLoad()

		getAccess()
		getAllEventsFromSource()
		
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}
	
	
	func getAccess() {
		let eventStore = EKEventStore()
		eventStore.requestAccess(to: .event) { (accessGranted, error) in
			if accessGranted == true {
				var destSet = false
				let calendars = eventStore.calendars(for: .event)
				for calendar in calendars {
					
					if calendar.title == self.sourcename {
						self.sCalendar = calendar
					}
					if calendar.title == self.destname {
						self.dCalendar = calendar
						destSet = true
					}
				}
				if destSet == false {
					let lightBlue = NSColor(red: 1/255, green: 110/255, blue: 200/255, alpha: 1)
					let newCalendar = EKCalendar.init(for: .event, eventStore: eventStore)
					newCalendar.title = self.destname
					newCalendar.source = eventStore.defaultCalendarForNewEvents?.source
					newCalendar.color = lightBlue
					do {
						try eventStore.saveCalendar(newCalendar, commit: true)
						print("destination calender created")
						self.dCalendar = newCalendar
					} catch {
						print("nope")
					}
				}
				print("Access Granted")
			} else {
				print("Access denied - requestAccessToCalendar")
			}
			
		}
	}

	private func getAllEventsFromSource() {
		let sourceCal = sCalendar
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"
		
		let startDate = dateFormatter.date(from: "2018-07-01")
		let endDate = dateFormatter.date(from: "2018-12-01") //.addingTimeInterval(60*60*24*366)
		
		let eventStore = EKEventStore()
		
		let eventsPredicate = eventStore.predicateForEvents(withStart: startDate!, end: endDate!, calendars: [sourceCal])
		self.events = eventStore.events(matching: eventsPredicate)
		
		eventStore.requestAccess(to: .event, completion: { (granted, error) in
			if (granted) && (error == nil) {
				self.events = eventStore.events(matching: eventsPredicate).sorted(){
					(e1: EKEvent, e2: EKEvent) -> Bool in
					return e1.startDate.compare(e2.startDate) == ComparisonResult.orderedAscending
				}
				for event in self.events {
					let newevent = event
					newevent.calendar = self.dCalendar
					do {
						print(newevent)
				//		try eventStore.save(newevent, span: .futureEvents, commit: true)
						
					} catch let e as NSError {
						print(e)
					}
				}
			}
		})
		
	}

	private func writeEventsIntoDestinationCalendar() {
		
	}
}

