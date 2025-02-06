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

  def getNote
    token = request.headers["Authorization"]&.split(" ")&.last
    result = NoteService.getNote(token)
    if result[:success]
      render json: result[:body], status: :ok
    else 
      render json: {errors: result[:error]}, status: :unprocessable_entity
    end
  end

  def getNoteById
    token = request.headers["Authorization"]&.split(" ")&.last
    note_id = params[:id]
    result = NoteService.getNoteById(note_id,token)
    if result[:success]
      render json: result[:note], status: :ok
    else
      render json: {errors: result[:error]}
    end
  end

  def trashToggle
    note_id = params[:id]
    result = NoteService.trashToggle(note_id)
    if result[:success]
      render json: {message: result[:message]}, status: :ok
    else
      render json: {errors: result[:errors]}, status: :bad_request
    end
  end

  def archiveToggle
    note_id = params[:id]
    result = NoteService.archiveToggle(note_id)
    if result[:success]
      render json: {message: result[:message]}, status: :ok
    else
      render json: {errors: result[:errors]}, status: :bad_request
    end
  end

  def changeColor
    note_id = params[:id]
    result = NoteService.changeColor(note_id,color_params)
    if result[:success]
      render json: {message: result[:message]}, status: :ok
    else
      render json: {errors: result[:errors]}, status: :bad_request
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