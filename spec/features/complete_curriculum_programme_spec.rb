require 'rails_helper'

feature 'Complete Curriculum Programme page', type: :feature do
  context 'Viewing the page' do
    let! :complete_curriculum_programme do
      create :complete_curriculum_programme
    end

    let! :units do
      create_list \
        :unit, 6, complete_curriculum_programme: complete_curriculum_programme
    end

    before do
      units.each do |unit|
        create_list :lesson, 6, unit: unit
      end
    end

    before do
      visit "/complete_curriculum_programmes/#{complete_curriculum_programme.id}"
    end

    it "shows the cpp name as the page title" do
      expect(page).to have_css 'h1', text: complete_curriculum_programme.name
    end

    context 'Unit cards' do
      it "shows a card for each unit" do
        units.each do |unit|
          expect(page).to have_css 'h3', text: unit.name
          expect(page).to have_link 'View and plan lessons', href: unit_path(unit)
          unit.lessons.each do |lesson|
            expect(page).to have_link(lesson.name, href: lesson_path(lesson))
          end
        end
      end
    end
  end
end
