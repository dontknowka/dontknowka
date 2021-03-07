root to: 'home#index'
get '/login', to: 'home#login', as: :login
post '/login', to: 'home#auth', as: :auth

get '/fix_ass', to: 'home#fix_ass', as: :fix_ass
post '/add_team_to_repos', to: 'home#add_team_to_repos', as: :add_team_to_repos
post '/add_team_to_reviewers', to: 'home#add_team_to_reviewers', as: :add_team_to_reviewers
post '/create_teacher', to: 'home#create_teacher', as: :create_teacher

post '/test', to: 'home#test'

resources :homeworks, except: [:show]
resources :instances, except: [:show]
resources :sets, except: [:show]
resources :ta_mappings, except: [:show]
