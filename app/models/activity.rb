class Activity < ContentBase
  attr_accessor :duration, :weight, :taxonomies

  alias overview content

  def from_file(file)
    super
  end

  def slug
    ActiveSupport::Inflector.parameterize(
      File.basename(filename, File.extname(filename))
    )
  end

  def lesson
    @lesson ||= Lesson.new
    @lesson.from_file(File.join(@filename.parent, "_index.md"))
    @lesson
  end

  def path
    Rails.application.routes.url_helpers.teachers_complete_curriculum_programme_unit_lesson_activity_path(
      lesson.unit.ccp,
      lesson.unit,
      lesson,
      self
    )
  end

  def part
    File.basename(@filename, File.extname(@filename)).to_f
  end

  alias number part

  # TODO need to understand the difference between types
  def activity_type
    taxonomies.first
  end

  # TODO select from a set of possible taxonomies that are the "involvement"
  def involvement
    ''
  end

  # TODO collect file formats from an array of resources array field in this activity
  def file_formats
    []
  end

  def extra_requirements
    []
  end

  def alternatives
    files = Dir.glob(File.join(@filename, "*.md"))
    filtered_files = files.select do |file|
      !file.end_with?("_index.md") || file.end_with?(@filename.basename)
    end
    filtered_files.collect do |file|
      self.class.from_file(file)
    end
  end
end
