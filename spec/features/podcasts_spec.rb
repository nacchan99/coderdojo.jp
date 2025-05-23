require 'rails_helper'

RSpec.feature 'Podcasts', type: :feature do
  describe 'GET documents' do
    scenario 'Podcast index should be exist' do
      visit '/podcasts'
      expect(page).to have_http_status(:success)
    end

    scenario 'Charter should be exist' do
      @podcast = create(:podcast)
      allow(@podcast).to receive(:exist?) { true }
      allow(@podcast).to receive(:exist?).with(offset: -1) { false }
      allow(@podcast).to receive(:content) { "title\n収録日: 2019/05/10\n..." }
      allow(Podcast).to  receive(:find_by).with(id: @podcast.id.to_s) { @podcast }

      visit "/podcasts/#{@podcast.id}"
      expect(page).to have_http_status(:success)

      target = 'Top'
      expect(page).to have_link target, href: podcasts_path
      click_link target, match: :first
      expect(page).to have_http_status(:success)
    end

    scenario 'Load doc file with absolute path' do
      @podcast = create(:podcast)
      allow(@podcast).to receive(:exist?) { true }
      allow(@podcast).to receive(:content) { "title\n収録日: 2019/05/10\n..." }
      allow(Podcast).to  receive(:find_by).with(id: @podcast.id.to_s) { @podcast }

      visit  "/podcasts/#{@podcast.id}"
      target = 'DojoCast'
      expect(page).to have_http_status(:success)
      expect(page).to have_link target, href: '/podcasts'
      click_link target, match: :first
      expect(page).to have_http_status(:success)
    end
  end
end
