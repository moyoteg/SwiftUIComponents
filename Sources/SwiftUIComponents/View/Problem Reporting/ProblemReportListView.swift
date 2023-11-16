//
//  SwiftUIView.swift
//
//
//  Created by Moi Gutierrez on 11/8/23.
//

import SwiftUI

import FirebaseFirestore
import FirebaseFirestoreSwift
import CloudyLogs

public struct ProblemReport: Identifiable, Codable {
    @DocumentID public var id: String?
    public var timestamp: Timestamp
    public var appVersion: String
    public var appBuild: String
    public var description: String
    public var viewName: String
    public var deviceModel: String
    public var deviceSystemVersion: String
    public var userID: String
    public var logFileURL: String?
    public var imageURL: String?
    public var takenCareOf: Bool
    
    public init(
        timestamp: Timestamp,
        appVersion: String,
        appBuild: String,
        description: String,
        viewName: String,
        deviceModel: String,
        deviceSystemVersion: String,
        userID: String,
        logFileURL: String?,
        imageURL: String?,
        takenCareOf: Bool = false
    ) {
        self.timestamp = timestamp
        self.appVersion = appVersion
        self.appBuild = appBuild
        self.description = description
        self.viewName = viewName
        self.deviceModel = deviceModel
        self.deviceSystemVersion = deviceSystemVersion
        self.userID = userID
        self.logFileURL = logFileURL
        self.imageURL = imageURL
        self.takenCareOf = takenCareOf
    }
}

public struct ProblemReportListView: View {
    @State private var problemReports: [ProblemReport] = []
    @State private var selectedFilter: Filter = .allReports
    @State private var isRefreshing = false
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            VStack {
                Picker("Filter", selection: $selectedFilter) {
                    Text("All Reports").tag(Filter.allReports)
                    Text("Taken Care Of").tag(Filter.takenCareOf)
                    Text("Not Taken Care Of").tag(Filter.notTakenCareOf)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                List {
                    ForEach(filteredReports) { report in
                        NavigationLink(
                            destination: ProblemReportDetailView(report: report),
                            label: {
                                VStack(alignment: .leading) {
                                    Text(report.description)
                                        .font(.headline)
                                    Text("Timestamp: \(report.timestamp.dateValue())")
                                        .font(.subheadline)
                                }
                            }
                        )
                        .swipeActions {
                            Button(role: .destructive) {
                                // Handle marking the report as "taken care of"
                                markReportAsTakenCareOf(report)
                            } label: {
                                Label("Taken Care Of", systemImage: "checkmark.circle.fill")
                            }
                        }
                    }
                }
                .listStyle(GroupedListStyle())
                .navigationTitle("Problem Reports")
                .refreshable {
                    // Handle refreshing the list here
                    refreshProblemReports()
                }
                .onAppear {
                    fetchProblemReports()
                }
            }
        }
    }
    
    private var filteredReports: [ProblemReport] {
        switch selectedFilter {
        case .allReports:
            return problemReports
        case .takenCareOf:
            return problemReports.filter { $0.takenCareOf }
        case .notTakenCareOf:
            return problemReports.filter { !$0.takenCareOf }
        }
    }
    
    public func fetchProblemReports() {
        let db = Firestore.firestore()
        db.collection("problemReports")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    Logger.log("Error fetching problem reports: \(error.localizedDescription)", logType: .error)
                    return
                }
                
                do {
                    if let documents = querySnapshot?.documents {
                        problemReports = try documents.map { document in
                            try document.data(as: ProblemReport.self)
                        }
                    }
                } catch {
                    Logger.log("Error mapping Firestore documents to ProblemReport objects: \(error.localizedDescription)", logType: .error)
                }
            }
    }

    public func refreshProblemReports() {
        isRefreshing = true
        // Fetch problem reports and update the list
        fetchProblemReports()
        isRefreshing = false
    }
    
    private func markReportAsTakenCareOf(_ report: ProblemReport) {
        // Mark the report as "taken care of" in Firestore
        let db = Firestore.firestore()
        if let reportID = report.id {
            db.collection("problemReports").document(reportID).updateData(["takenCareOf": true]) { error in
                if let error = error {
                    print("Error marking report as taken care of: \(error.localizedDescription)")
                } else {
                    // Update the local problemReports array to reflect the change
                    if let index = problemReports.firstIndex(where: { $0.id == reportID }) {
                        problemReports[index].takenCareOf = true
                    }
                }
            }
        }
    }
    
    private enum Filter: Int {
        case allReports
        case takenCareOf
        case notTakenCareOf
    }
}

public struct ProblemReportDetailView: View {
    public var report: ProblemReport
    
    public init(report: ProblemReport) {
        self.report = report
    }
    
    public var body: some View {
        List {
            Section(header: Text("Description")) {
                Text(report.description)
                    .font(.body)
                    .textSelection(.enabled)
            }
            
            Section(header: Text("Timestamp")) {
                Text(report.timestamp.dateValue().formatted(.dateTime))
                    .font(.body)
                    .textSelection(.enabled)
            }
            
            Section(header: Text("App Version")) {
                Text(report.appVersion)
                    .font(.body)
                    .textSelection(.enabled)
            }
            
            Section(header: Text("App Build")) {
                Text(report.appBuild)
                    .font(.body)
                    .textSelection(.enabled)
            }
            
            Section(header: Text("View Name")) {
                Text(report.viewName)
                    .font(.body)
                    .textSelection(.enabled)
            }
            
            Section(header: Text("Device Model")) {
                Text(report.deviceModel)
                    .font(.body)
                    .textSelection(.enabled)
            }
            
            Section(header: Text("Device System Version")) {
                Text(report.deviceSystemVersion)
                    .font(.body)
                    .textSelection(.enabled)
            }
            
            if let logFileURL = report.logFileURL {
                Section(header: Text("Log File")) {
                    Button(action: {
                        openURL(urlString: logFileURL)
                    }) {
                        Text("Open Log File")
                            .foregroundColor(.blue)
                    }
                }
            }
            
            if let imageURL = report.imageURL {
                Section(header: Text("Image")) {
                    Button(action: {
                        openURL(urlString: imageURL)
                    }) {
                        Text("Open Image")
                            .foregroundColor(.blue)
                    }
                    AutoImage(imageURL)
                        .resizable()
                        .frame(maxWidth: .infinity, maxHeight: 200)
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle("Report Details")
    }
    
    private func openURL(urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}
