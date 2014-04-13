Jaccitback::Application.routes.draw do
  match '/seek/:username', to: 'game#seek', via: [:get, :post]
  match '/check/:username', to: 'game#check', via: [:get]
  match '/finished/:username/:score', to: 'game#finished', via: [:get, :post]
  match '/postgame/:username', to: 'game#postgame', via: [:get]
  match '/interrupt/:username', to: 'game#interrupt', via: [:get, :post]
end
