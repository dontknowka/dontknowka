root to: 'home#index'
get '/login', to: 'home#login', as: :login
post '/login', to: 'home#auth', as: :auth

get '/fix_ass', to: 'home#fix_ass', as: :fix_ass
get '/fix_reviews', to: 'home#fix_reviews', as: :fix_reviews
post '/add_team_to_repos', to: 'home#add_team_to_repos', as: :add_team_to_repos
post '/add_team_to_reviewers', to: 'home#add_team_to_reviewers', as: :add_team_to_reviewers
post '/create_teacher', to: 'home#create_teacher', as: :create_teacher
post '/collect_interviews', to: 'home#collect_interviews', as: :collect_interviews

post '/test', to: 'home#test'

resources :homeworks, except: [:edit]
resources :instances, except: [:show, :edit]
resources :sets, except: [:show, :edit]
resources :ta_mappings, except: [:show, :edit]
resources :teachers, only: [:index, :create, :destroy]
resources :teams, only: [:index, :create, :destroy]
resources :teacher_mappings, only: [:index, :create, :destroy]
resources :team_mappings, only: [:index, :create, :destroy]
resources :bonuses, only: [:index, :create, :update, :destroy]
resources :competitions, only: [:index, :create, :destroy]
get '/teachers/populate', to: 'teachers#populate', as: :populate_teachers
get '/teams/populate', to: 'teams#populate', as: :populate_teams

get '/students', to: 'students#index', as: :students
get '/students/:id', to: 'students#view', as: :student
