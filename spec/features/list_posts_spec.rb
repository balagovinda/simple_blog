require 'spec_helper'

feature 'List posts' do
  background do
    create_a_blog_post(:title => 'Blog post title',
                       :body => 'Blog post body',
                       :tags => 'first tag, second tag',
                       :description => 'Blog post description',
                       :keywords => 'first keyword, second keyword')
  end

  scenario 'should only show articles of the current locale' do
    create_a_blog_post(:title => 'Romanian blog post', :language => 'Romanian')
    I18n.locale = 'ro'
    visit blog_posts_path
    expect(page).to have_content('Romanian Blog Post')
    expect(page).not_to have_content('Blog Post Title')
    I18n.locale = 'en'
  end

  scenario "should only display the post's descsription" do
    visit blog_posts_path
    expect(page).to have_content('Blog post description')
    expect(page).not_to have_content('Blog post body')
  end

  scenario 'all the published posts are displayed' do
    create_a_blog_post(:title => 'Unpublished post title', :unpublished => true)
    visit blog_posts_path
    expect(page).to have_content('Blog Post Title')
    expect(page).not_to have_content('Unpublished Post title')
  end

  scenario 'posts show tags on index page' do
    visit blog_posts_path
    expect(page).to have_content('First Tag')
  end

  scenario 'filtering by tag returns only posts with that tag' do
    create_a_blog_post(:title => 'Differnt tag blog post title', :tags => 'different tag')
    visit blog_posts_path
    click_link('First Tag', :match => :first)
    expect(page).to have_content('Blog Post Title')
    expect(page).not_to have_content('Different Tag Blog Post Title')
  end

  scenario 'filtering by tag sets the page title to the capitalize tag' do
    visit blog_posts_path
    click_on("First Tag")
    expect(page).to have_title("First Tag")
  end

  scenario "filtering by tag that doesn't exist should 404" do
    expect {
      visit filter_posts_path(:tag => "not_a_tag")
    }.to raise_exception(ActiveRecord::RecordNotFound)
  end
end
