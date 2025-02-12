require 'swagger_helper'

RSpec.describe 'Notes API', type: :request do
  path '/api/v1/notes' do
    post 'Create a new note' do
      tags 'Notes'
      consumes 'application/json'
      security [ BearerAuth: [] ]  # Requires JWT Authentication
      parameter name: :note, in: :body, schema: {
        type: :object,
        properties: {
          content: { type: :string }
        },
        required: [ 'content' ]
      }

      response '200', 'Note added successfully' do
        let(:note) { { content: 'This is a new note' } }
        run_test!
      end

      response '422', 'Invalid request' do
        let(:note) { { content: '' } } # Content is required
        run_test!
      end

      response '401', 'Unauthorized access' do
        let(:note) { { content: 'This is a new note' } }
        before do
          # Simulating an invalid or expired JWT token
          request.headers['Authorization'] = 'Bearer invalid_token'
        end
        run_test!
      end
    end
  end

  path '/api/v1/notes/getNoteById/{id}' do
    get 'Get a note by ID' do
      tags 'Notes'
      security [ BearerAuth: [] ]
      parameter name: :id, in: :path, type: :string

      response '200', 'Note found successfully' do
        let(:id) { Note.create(content: 'Sample note').id }
        run_test!
      end

      response '404', 'Note not found' do
        let(:id) { 'invalid' }
        run_test!
      end

      response '401', 'Unauthorized access' do
        let(:id) { Note.create(content: 'Sample note').id }
        before do
          # Simulating an invalid or expired JWT token
          request.headers['Authorization'] = 'Bearer invalid_token'
        end
        run_test!
      end
    end
  end

  path '/api/v1/notes/getNote' do
    get 'Get all notes for the authenticated user' do
      tags 'Notes'
      security [ BearerAuth: [] ]

      response '200', 'Notes retrieved successfully' do
        before do
          token = JsonWebToken.encode(id: user.id)
          request.headers['Authorization'] = "Bearer #{token}"
          allow(@@redis).to receive(:get).and_return(nil)
          allow(@@redis).to receive(:set)
          create_list(:note, 3, user: user)
        end
        run_test!
      end

      response '401', 'Unauthorized access' do
        before do
          request.headers['Authorization'] = 'Bearer invalid_token'
        end
        run_test!
      end

      response '422', 'No notes found' do
        before do
          token = JsonWebToken.encode(id: user.id)
          request.headers['Authorization'] = "Bearer #{token}"
          allow(@@redis).to receive(:get).and_return(nil)
          allow_any_instance_of(User).to receive(:notes).and_return([])
        end
        run_test!
      end
    end
  end


  path '/api/v1/notes/trashToggle/{id}' do
    delete 'Delete a note (soft delete)' do
      tags 'Notes'
      parameter name: :id, in: :path, type: :string

      response '200', 'Note deleted/restored successfully' do
        let(:id) { Note.create(content: 'Sample note to delete').id }
        run_test!
      end

      response '404', 'Note not found' do
        let(:id) { 'invalid' }
        run_test!
      end
    end
  end


  path '/api/v1/notes/archiveToggle/{id}' do
    put 'Toggle Archive Status' do
      tags 'Notes'
      parameter name: :id, in: :path, type: :string

      response '200', 'Note archived/unarchived successfully' do
        before do
          note = Note.create(content: 'Sample note to toggle archive')
          post "/api/v1/notes/archiveToggle/#{note.id}"
        end
        run_test!
      end

      response '404', 'Note not found' do
        before do
          post '/api/v1/notes/archiveToggle/invalid'
        end
        run_test!
      end
    end
  end

  path '/api/v1/notes/changeColor/{id}' do
    put 'Change Note Color' do
      tags 'Notes'
      consumes 'application/json'
      parameter name: :id, in: :path, type: :string
      parameter name: :color, in: :body, schema: {
        type: :object,
        properties: {
          color: { type: :string }
        },
        required: [ 'color' ]
      }

      response '200', 'Color changed successfully' do
        let(:id) { 'some-note-id' }
        let(:color) { { color: '#FF5733' } }
        run_test!
      end

      response '422', 'Invalid request' do
        let(:id) { 'some-note-id' }
        let(:color) { { color: '' } }  # Color is required
        run_test!
      end

      response '404', 'Note not found' do
        let(:id) { 'invalid-note-id' }
        let(:color) { { color: '#FF5733' } }
        run_test!
      end
    end
  end
end
