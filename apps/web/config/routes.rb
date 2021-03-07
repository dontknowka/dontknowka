root to: 'home#index'

get '/student', to: 'students#home', as: :student
get '/student/profile', to: 'students#profile', as: :student_profile
post '/student/profile', to: 'students#profile'
get '/student/new', to: 'students#new', as: :new_student_auth
post '/student/new', to: 'students#new_auth'

get '/login', to: "sessions#new", as: :login
get '/auth', to: "sessions#auth", as: :auth

post '/set', to: 'set#choose', as: :choose_set
