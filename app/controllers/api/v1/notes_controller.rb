class Api::V1::NotesController < ApplicationController
  skip_before_action :verify_authenticity_token
  def addNote
    token = request.headers["Authorization"]&.split(" ")&.last
    result = NoteService.addNote(note_params,token)
    if result[:success]
      render json: {message: result[:message]}, status: :ok
    else
      render json: {errors: result[:error]}, status: :unprocessable_entity
    end
  end

  private
  def note_params
    params.require(:note).permit(:content)
  end

  def color_params
    params.require(:note).permit(:color)
  end
end
