root to: 'home#index'

get '/student', to: 'students#home', as: :student
get '/student/profile', to: 'students#profile', as: :student_profile
post '/student/profile', to: 'students#profile'
get '/student/new', to: 'students#new', as: :new_student_auth
post '/student/new', to: 'students#new_auth'
get '/student/score', to: 'students#score', as: :student_score

get '/login', to: "sessions#new", as: :login
get '/auth', to: "sessions#auth", as: :auth

post '/set', to: 'set#choose', as: :choose_set

get '/teacher', to: 'teacher#home', as: :teacher
get '/teacher/profile', to: 'teacher#profile', as: :teacher_profile
post '/teacher/profile', to: 'teacher#profile'
get '/teacher/favorites', to: 'teacher#favorites', as: :teacher_favorites
post '/teacher/favorites', to: 'teacher#favorites'
get '/teacher/assignments', to: 'teacher#assignments', as: :teacher_assignments
