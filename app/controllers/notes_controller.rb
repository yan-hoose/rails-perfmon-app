class NotesController < ApplicationController
  layout 'reports'
  before_action :set_website, only: [:index, :new, :create, :edit, :update, :destroy]
  before_action :set_note, only: [:edit, :update, :destroy]

  def index
    respond_to do |format|
      format.html
      format.json {
        render json: @website.notes.select('id, text, time').where('time >= ? AND time < ?',
          params[:start].to_date.in_time_zone, params[:end].to_date.in_time_zone + 1.day)
      }
    end
  end

  def new
    @note = @website.notes.new
  end

  def create
    @note = @website.notes.create note_params
    unless @note.new_record?
      redirect_to website_notes_path(@website), notice: 'Note added!'
    else
      render action: :new
    end
  end

  def update
    if @note.update note_params
      redirect_to website_notes_path(@website), notice: 'Note updated!'
    else
      render action: :edit
    end
  end

  def destroy
    @note.destroy
    redirect_to website_notes_path(@website), notice: 'Note deleted!'
  end

private

  def set_website
    @website = @current_user.websites.find(params[:website_id])
  end

  def set_note
    @note = @website.notes.find(params[:id])
  end

  def note_params
    params.require(:note).permit(:time, :text)
  end

end
