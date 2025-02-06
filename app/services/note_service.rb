class NoteService
    def self.addNote(note_params,token)
      user_data = JsonWebToken.decode(token)
      unless user_data
        return {success: false, error: "Unauthorized access" }
      end
      note = user_data.notes.new(note_params)
      if note.save
        return {success: true, message: "Note added successfully"}
      else
        return {success: false, error: "Couldn't add note"}
      end
    end
end