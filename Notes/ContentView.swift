//
//  ContentView.swift
//  Notes
//
//  Created by James Jolly on 2/13/25.
//

import SwiftUI

struct Note: Identifiable
{
    var id = UUID()
    var title: String
    var content: String
    var isCompleted: Bool = false
}

class NotesViewModel: ObservableObject
{
    @Published var notes: [Note] = []
    
    func addNote(title: String, content: String)
    {
        let newNote = Note(title: title, content: content)
        notes.append(newNote)
    }
    
    func editNote(id: UUID, title: String, content: String)
    {
        if let index = notes.firstIndex(where: {$0.id == id}) {
            notes[index].title = title
            notes[index].content = content
        }
    }
    
    func toggleCompletion(for note: Note)
    {
        if let index = notes.firstIndex(where: { $0.id == note.id})
        {
            notes[index].isCompleted.toggle()
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = NotesViewModel()
    @State private var newNoteTitle = ""
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(viewModel.notes) { note in
                        NavigationLink(destination: ReadNoteView(viewModel: viewModel, note: note)) {
                            HStack {
                                Text(note.title)
                                    .strikethrough(note.isCompleted, color: .black)
                                    
                                Spacer()
                                    
                                Button(action: {
                                    viewModel.toggleCompletion(for: note)
                                }) {
                                    Image(systemName: note.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(note.isCompleted ? .green : .gray)
                                }
                            }
                        }
                    }
                    .onDelete { indexSet in
                        viewModel.notes.remove(atOffsets: indexSet)
                    }
                }
            }
            .navigationBarTitle("Notes")
            .navigationBarItems(trailing: NavigationLink(
                destination: NewNoteView(viewModel: viewModel)) {
                Image(systemName: "plus")
                    .font(.title)
                    .foregroundColor(.blue)
            })
        }
    }
    
    @State private var showingAddNoteAlert = false
    
    func showAddNoteAlert() {
        showingAddNoteAlert.toggle()
    }
}

struct NewNoteView: View {
    @ObservedObject var viewModel: NotesViewModel
    @State private var title = ""
    @State private var content = ""
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            TextField("Title", text: $title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextEditor(text: $content)
                .border(Color.gray, width: 1)
                .padding()
            
            Spacer()
        }
        .navigationBarTitle("Add Note", displayMode: .inline)
        .navigationBarItems(leading: Button("") { },
                            trailing: Button("Save"){
            if !title.isEmpty && !content.isEmpty {
                viewModel.addNote(title: title, content: content)
                presentationMode.wrappedValue.dismiss()
            }
        })
    }
}

struct EditNoteView: View {
    @ObservedObject var viewModel: NotesViewModel
    @State private var title: String
    @State private var content: String
    @State private var isCompleted: Bool
    
    @Environment(\.presentationMode) var presentationMode
    
    var note: Note
    
    init(viewModel: NotesViewModel, note: Note) {
        self.viewModel = viewModel
        self.note = note
        _title = State(initialValue: note.title)
        _content = State(initialValue: note.content)
        _isCompleted = State(initialValue: note.isCompleted)
    }
    
    var body: some View {
        VStack {
            TextField("Title", text: $title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextEditor(text: $content)
                .border(Color.gray, width: 1)
                .padding()
            
            Spacer()
            
        }
        .navigationBarTitle("Edit Note", displayMode: .inline)
        .navigationBarItems(leading: Button("") { },
                            trailing: Button("Save"){
            if !title.isEmpty && !content.isEmpty {
                viewModel.editNote(id: note.id, title: title, content: content)
                presentationMode.wrappedValue.dismiss()
            }
        })
    }
}

struct ReadNoteView: View {
    @ObservedObject var viewModel: NotesViewModel
    @State private var note: Note
    
    @Environment(\.presentationMode) var presentationMode
    
    
    init(viewModel: NotesViewModel, note: Note) {
        self.viewModel = viewModel
        _note = State(initialValue: note)
    }
    
    var body: some View {
        
        VStack(alignment: .leading) {
            Text(note.title)
                .font(.title)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ScrollView {
                Text(note.content)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Spacer()
            
            Button(action: {
                viewModel.toggleCompletion(for: note)
                note.isCompleted.toggle()
            }) {
                Text(note.isCompleted ? "Mark as Uncompleted" : "Mark as Completed")
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .padding()
                    .background(note.isCompleted ? Color.orange : Color.green)
                    .cornerRadius(10)
            }
            
            .padding(.horizontal)
            .padding(.bottom)
        }
        .navigationBarTitle("Note Details", displayMode: .inline)
        .navigationBarItems(leading: Button("") { },
                            trailing: NavigationLink(destination: EditNoteView(viewModel: viewModel, note: note)) {
            Text("Edit")
                .foregroundColor(.blue)
        })
        .onAppear {
            if let updatedNote = viewModel.notes.first(where: { $0.id == note.id }) {
                self.note = updatedNote
            }
        }
    }
}


#Preview {
    ContentView()
}
