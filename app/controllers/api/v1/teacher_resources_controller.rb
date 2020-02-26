class Api::V1::TeacherResourcesController < Api::BaseController
  def index
    render json: SimpleAMS::Renderer::Collection.new(
      teacher_resources,
      serializer: TeacherResourceSerializer,
      includes: []
    ).to_json
  end

  def create
    if teacher_resources.attach teacher_resource_params
      head :created
    else
      render json: { errors: activity.errors.full_messages }, status: :bad_request
    end
  end

  def destroy
    teacher_resource = teacher_resources.find params[:id]
    teacher_resource.purge
    head :no_content
  end

private

  def teacher_resources
    @teacher_resources ||= activity.teacher_resources
  end

  def activity
    @activity ||= Activity.with_attached_teacher_resources.find params[:activity_id]
  end

  def teacher_resource_params
    params.require :teacher_resource
  end
end
