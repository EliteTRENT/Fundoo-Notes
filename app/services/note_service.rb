class NoteService
  @@redis = Redis.new(host: "localhost", port: 6379)
  def self.addNote(note_params, token)
    user_data = JsonWebToken.decode(token)
    unless user_data
      return { success: false, error: "Unauthorized access" }
    end
    note = user_data.notes.new(note_params)
    if note.save
      { success: true, message: "Note added successfully" }
    else
      { success: false, error: "Couldn't add note" }
    end
  end

  def self.getNote(token)
    @current_user = JsonWebToken.decode(token)
    return { success: false, error: "Unauthorized access" } unless @current_user

    user_id = @current_user.id
    cache_key = "user_#{user_id}_notes"
    cached_notes = @@redis.get(cache_key)
    if cached_notes
      return { success: true, notes: JSON.parse(cached_notes) }
    end
    notes = @current_user.notes
    return { success: false, error: "No notes found" } unless notes.any?
    @@redis.set(cache_key, notes.to_json, ex: 300)

    { success: true, notes: notes }
  end

  def self.getNoteById(note_id, token)
    user_data = JsonWebToken.decode(token)
    note = Note.find_by(id: note_id)
    unless user_data
      return { success: false, error: "Unauthorized access" }
    end
    if user_data[:id] == note.user_id
      { success: true, note: note }
    else
      { success: false, error: "Token not valid for this note" }
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
      { success: true, message: "Status toggled" }
    else
      { success: false, errors: "Couldn't toggle the status" }
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
      { success: true, message: "Status toggled" }
    else
      { success: false, errors: "Couldn't toggle the status" }
    end
  end

  def self.changeColor(note_id, color_params)
    note = Note.find_by(id: note_id)
    if note
      note.update(color: color_params[:color])
      { success: true, message: "Color changed" }
    else
      { success: false, errors: "Couldn't change the color" }
    end
  end
end
