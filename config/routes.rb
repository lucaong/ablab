Ablab::Engine.routes.draw do
  get '/track', to: 'base#track'

  root to: 'base#dashboard'
end
