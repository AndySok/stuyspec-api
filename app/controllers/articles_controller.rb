class ArticlesController < ApplicationController
  before_action :set_article, only: [:show, :update, :destroy]
  before_action :authenticate_admin!, only: [:create, :update, :destroy]

  # GET /articles
  def index
    if params[:section_id]
      @section = Section.friendly.find(params[:section_id])
      @articles = Article.where("section_id = ?", @section.id)
    else
      @articles = Article.all
    end

    if params[:query]
      @articles = PgSearch.multisearch(params[:query])
    end

    @articles = @articles.order(:created_at).reverse if params[:order_by] == 'date'

    @articles = @articles.first(params[:limit].to_i) if params[:limit]

    @articles = @articles.select(
      :id,
      :title,
      :slug,
      :volume,
      :issue,
      :is_published,
      :created_at,
      :updated_at,
      :section_id,
      :rank,
      :summary
    ) if params[:content] == 'false'

    render json: @articles, methods: [:ranking]
  end

  # GET /articles/1
  def show
    render json: @article
  end

  # POST /articles
  def create
    @section = Section.friendly.find(params[:section_id])
    @article = @section.articles.build(article_params)

   if @article.save
      render json: @article, status: :created, location: @article
   else
      render json: @article.errors, status: :unprocessable_entity
   end
  end

  # PATCH/PUT /articles/1
  def update
    if @article.update(article_params)
      render json: @article
    else
      render json: @article.errors, status: :unprocessable_entity
    end
  end

  # DELETE /articles/1
  def destroy
    @article.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_article
      @article = Article.friendly.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def article_params
      params.require(:article).permit(
        :title,
        :slug,
        :content,
        :volume,
        :issue,
        :is_published,
        :section_id,
        :summary,
        :rank,
        :created_at
      )
    end
    def find_combined_rank(article)
      return article.rank + Section.friendly.find(article.section_id).rank * 1.5
    end
end
