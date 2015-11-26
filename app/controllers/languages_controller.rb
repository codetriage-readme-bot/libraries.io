class LanguagesController < ApplicationController
  def index
    @languages = Project.popular_languages(:facet_limit => 160)
  end

  def show
    find_language

    @created = Project.language(@language).not_deprecated.few_versions.order('projects.created_at DESC').limit(5).includes(:github_repository)
    @updated = Project.language(@language).not_deprecated.many_versions.order('projects.latest_release_published_at DESC').limit(5).includes(:github_repository)
    @color = Languages::Language[@language].try(:color)
    @watched = Project.language(@language).not_deprecated.most_watched.limit(5)
    @dependend = Project.language(@language).not_deprecated.most_dependents.limit(5).includes(:github_repository)
    @popular = Project.language(@language).not_deprecated.order('projects.rank DESC').limit(5).includes(:github_repository)

    facets = Project.facets(filters: { language: @language }, :facet_limit => 10)

    @platforms = facets[:platforms][:terms]
    @licenses = facets[:licenses][:terms].reject{ |t| t.term.downcase == 'other' }
    @keywords = facets[:keywords][:terms]
  end

  def find_language
    @language = Project.language(params[:id]).first.try(:language)
    raise ActiveRecord::RecordNotFound if @language.nil?
    redirect_to language_path(@language), :status => :moved_permanently if @language != params[:id]
  end
end
