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

  def self.getNote(token)
    user_data = JsonWebToken.decode(token)
    unless user_data
      return {success: false, error: "Unauthorized access" }
    end
    note = user_data.notes.where(isDeleted: false, isArchive: false).includes(:user)
    if note
      # notes_with_user = note.each do |note|
      #   {
      #     note: note,
      #     user: note.user 
      #   }
      # end
        return { success: true, body: note}
    else
      return {success: false, error: "Couldn't get notes"}
    end
  end

  def self.getNoteById(note_id,token)
    user_data = JsonWebToken.decode(token)
    note = Note.find_by(id: note_id)
    unless user_data
      return {success: false, error: "Unauthorized access" }
    end
    if user_data[:id] == note.user_id
      return {success: true, note: note}
    else
      return {success: false, error: "Token not valid for this note"}
    end
  end

  def self.trashToggle(note_id)
    note = Note.find_by(id: note_id)
    if note
      if note.isDeleted == false
        note.update(isDeleted: true)
      else
        note.update(isDeleted: false)
      end
      return {success: true, message: "Status toggled"}
    else
      return {success: false, errors: "Couldn't toggle the status"}
    end
  end

  def self.archiveToggle(note_id)
    note = Note.find_by(id: note_id)
    if note
      if note.isArchive == false
        note.update(isArchive: true)
      else
        note.update(isArchive: false)
      end
      return {success: true, message: "Status toggled"}
    else
      return {success: false, errors: "Couldn't toggle the status"}
    end
  end
end