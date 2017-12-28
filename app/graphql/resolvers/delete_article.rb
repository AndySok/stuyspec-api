class Resolvers::DeleteArticle < Resolvers::MutationFunction
  # arguments passed as "args"
  argument :id, !types.ID

  # return type from the mutation
  type Types::ArticleType

  # the mutation method
   # _obj - is parent object, which in this case is nil
  # args - are the arguments passed
  # _ctx - is the GraphQL context (which would be discussed later)
  def call(_obj, args, ctx)
    if error = validate_user(ctx)
      return error
    end
    article = Article.find(args["id"]).destroy!
    generate_new_header(ctx) if article
    return article
  end
end
