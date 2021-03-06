require "rails_helper"

RSpec.describe Teachers::SessionsController, type: :request do
  let(:teacher) { create(:teacher) }

  describe '#create' do
    context 'when the token is valid' do
      subject { get(create_teachers_session_path(teacher.token)) }

      specify 'the teacher should be redirected to the landing page' do
        expect(subject).to redirect_to(root_path)
      end
    end

    context 'when the token is invalid' do
      let(:invalid_token) { 'aaaaaaaa-bbbb-cccc-1111-222222222222' }
      subject { get(create_teachers_session_path(invalid_token)) }

      specify 'the request should fail' do
        expect(subject).to be(400)
      end
    end
  end

  describe '#destroy' do
    specify 'after destroying the session protected pages should not be accessible' do
      # log in
      get(create_teachers_session_path(teacher.token))
      expect(get(teachers_home_path)).to be(200)

      # log out
      delete(teachers_session_path)
      expect(get(teachers_home_path)).to redirect_to('/pages/how-to-get-access')
    end
  end
end
