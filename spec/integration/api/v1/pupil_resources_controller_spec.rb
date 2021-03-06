require 'swagger_helper'

describe 'PupilResources' do
  include_context 'setup api token'

  let(:activity) { create(:activity) }
  let(:ccp_id) { activity.lesson_part.lesson.unit.complete_curriculum_programme.id }
  let(:unit_id) { activity.lesson_part.lesson.unit.id }
  let(:lesson_id) { activity.lesson_part.lesson.id }
  let(:lesson_part_id) { activity.lesson_part.id }
  let(:activity_id) { activity.id }

  path '/ccps/{ccp_id}/units/{unit_id}/lessons/{lesson_id}/lesson_parts/{lesson_part_id}/activities/{activity_id}/pupil_resources' do
    get %{Returns the activity's attached pupil_resources} do
      tags 'PupilResource'
      produces 'application/json'

      parameter name: 'Authorization', in: :header, type: :string
      parameter name: :ccp_id, in: :path, type: :string, required: true
      parameter name: :unit_id, in: :path, type: :string, required: true
      parameter name: :lesson_id, in: :path, type: :string, required: true
      parameter name: :lesson_part_id, in: :path, type: :string, required: true
      parameter name: :activity_id, in: :path, type: :string, required: true

      response '200', 'pupil resources found' do
        examples 'application/json': [{
          id: 1,
          file_url: 'https://example.com/path-to-resource',
          preview_url: 'https://example.com/path-to-resource'
        }]

        run_test!
      end

      response(401, 'unauthorized') do
        it_should_behave_like 'an endpoint that requires token auth'
      end
    end

    post 'Attaches a pupil resource to the activity' do
      tags 'PupilResource'
      consumes 'multipart/form-data'
      produces 'application/json'

      parameter name: 'Authorization', in: :header, type: :string
      parameter name: :ccp_id, in: :path, type: :string, required: true
      parameter name: :unit_id, in: :path, type: :string, required: true
      parameter name: :lesson_id, in: :path, type: :string, required: true
      parameter name: :lesson_part_id, in: :path, type: :string, required: true
      parameter name: :activity_id, in: :path, type: :string, required: true
      parameter name: 'pupil_resource[file]', in: :formData, type: :file, required: true
      parameter name: 'pupil_resource[preview]', in: :formData, type: :file, required: true

      response 201, 'pupil_resouce created' do
        let :attachment_path do
          File.join(Rails.application.root, 'spec', 'fixtures', '1px.png')
        end

        let 'pupil_resource[file]' do
          fixture_file_upload attachment_path, 'image/png'
        end

        let 'pupil_resource[preview]' do
          fixture_file_upload attachment_path, 'image/png'
        end

        request_body \
          content: {
            'multipart/form-data': {
              schema: {
                type: 'object',
                properties: {
                  'pupil_resource[file]': {
                    type: :string,
                    format: :binary
                  },
                  'pupil_resource[preview]': {
                    type: :string,
                    format: :binary
                  }
                }
              },
              encoding: {
                'pupil_resource[file]': {
                  contentType: PupilResource::ALLOWED_CONTENT_TYPES.join(',')
                },
                'pupil_resource[preview]': {
                  contentType: PupilResource::ALLOWED_PREVIEW_CONTENT_TYPES.join(',')
                }
              }
            }
          }

        run_test! do |response|
          expect(response.code).to eq '201'
        end
      end

      response 400, 'invalid pupil_resource' do
        let :attachment_path do
          File.join(Rails.application.root, 'spec', 'fixtures', 'sample.xml')
        end

        let 'pupil_resource[file]' do
          fixture_file_upload attachment_path, 'text/xml'
        end

        let 'pupil_resource[preview]' do
          fixture_file_upload attachment_path, 'text/xml'
        end

        run_test! do |response|
          expect(response.code).to eq '400'

          expect(JSON.parse(response.body).dig('errors')).to include \
            "File has an invalid content type"
        end
      end

      response(401, 'unauthorized') do
        let :attachment_path do
          File.join(Rails.application.root, 'spec', 'fixtures', 'sample.xml')
        end

        let 'pupil_resource[file]' do
          fixture_file_upload attachment_path, 'text/xml'
        end

        let 'pupil_resource[preview]' do
          fixture_file_upload attachment_path, 'text/xml'
        end

        it_should_behave_like 'an endpoint that requires token auth'
      end
    end
  end

  path '/ccps/{ccp_id}/units/{unit_id}/lessons/{lesson_id}/lesson_parts/{lesson_part_id}/activities/{activity_id}/pupil_resources/{pupil_resource_id}' do
    let :pupil_resource do
      create :pupil_resource, activity: activity
    end

    let :pupil_resource_id do
      pupil_resource.id
    end

    delete %{Removes the attached resource from the activity} do
      tags 'PupilResource'

      parameter name: 'Authorization', in: :header, type: :string
      parameter name: :ccp_id, in: :path, type: :string, required: true
      parameter name: :unit_id, in: :path, type: :string, required: true
      parameter name: :lesson_id, in: :path, type: :string, required: true
      parameter name: :lesson_part_id, in: :path, type: :string, required: true
      parameter name: :activity_id, in: :path, type: :string, required: true
      parameter name: :pupil_resource_id, in: :path, type: :string, required: true

      response '204', 'pupil resource removed' do
        run_test! do |response|
          expect(response.code).to eq '204'
          expect(activity.reload.pupil_resources).to be_empty
        end
      end

      response(401, 'unauthorized') do
        it_should_behave_like 'an endpoint that requires token auth'
      end
    end
  end
end
