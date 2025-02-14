require 'rails_helper'
require 'redis'

RSpec.describe NoteService, type: :service do
  let(:user) { User.create!(name: "John Doe", email: "john@example.com", password: "Password123@", phone_number: "+8907653241") }
  let(:token) { JsonWebToken.encode(id: user.id, name: user.name, email: user.email) }
  let(:invalid_token) { "invalid.token.here" }
  let(:note) { user.notes.create!(content: "This is a test note.", isDeleted: false, isArchive: false, color: "#FFFFFF") }

  describe "#addNote" do
    it "adds a note successfully" do
      note_params = { content: "This is a new note.", isDeleted: false, isArchive: false, color: "#FF5733" }
      result = NoteService.addNote(note_params, token)
      expect(result[:success]).to be true
      expect(result[:message]).to eq("Note added successfully")
    end

    it "returns an error when the token is invalid" do
      note_params = { content: "This is a new note.", isDeleted: false, isArchive: false, color: "#FF5733" }
      result = NoteService.addNote(note_params, invalid_token)
      expect(result[:success]).to be false
      expect(result[:error]).to eq("Unauthorized access")
    end
  end

  describe "#getNote" do
    it "retrieves user notes successfully" do
      # Ensure a note exists for the user
      user.notes.create!(content: "Another test note", isDeleted: false, isArchive: false, color: "#000000")

      result = NoteService.getNote(token)

      expect(result[:success]).to be true
      expect(result[:notes].first.content).to eq("Another test note")  # Updated to match the ActiveRecord object structure
    end

    it "returns an error when the token is invalid" do
      result = NoteService.getNote(invalid_token)
      expect(result[:success]).to be false
      expect(result[:error]).to eq("Unauthorized access")
    end
  end


  describe "#getNoteById" do
    it "retrieves a note successfully" do
      result = NoteService.getNoteById(note.id, token)
      expect(result[:success]).to be true
      expect(result[:note].content).to eq(note.content)
      expect(result[:note].isDeleted).to eq(note.isDeleted)
      expect(result[:note].isArchive).to eq(note.isArchive)
      expect(result[:note].color).to eq(note.color)
    end

    it "returns an error when the token is invalid" do
      result = NoteService.getNoteById(note.id, invalid_token)
      expect(result[:success]).to be false
      expect(result[:error]).to eq("Unauthorized access")
    end
  end

  describe "#trashToggle" do
    it "toggles the isDeleted status" do
      result = NoteService.trashToggle(note.id)
      expect(result[:success]).to be true
      expect(result[:message]).to eq("Status toggled")
    end
  end

  describe "#archiveToggle" do
    it "toggles the isArchive status" do
      result = NoteService.archiveToggle(note.id)
      expect(result[:success]).to be true
      expect(result[:message]).to eq("Status toggled")
    end
  end

  describe "#changeColor" do
    it "changes the color of the note" do
      color_params = { color: "#FF5733" }
      result = NoteService.changeColor(note.id, color_params)
      expect(result[:success]).to be true
      expect(result[:message]).to eq("Color changed")
    end
  end
end
