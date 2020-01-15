Rails.application.routes.draw do

  # scope "(:locale)", :locale => /#{I18n.available_locales.join('|')}/ do
    localized do
      # devise_for :users, :path => "auth", path_names: { sign_in: 'login', sign_out: 'logout' }, controllers: { cas_sessions: 'my_cas' }
      devise_for :users, path: 'auth', path_names: { sign_in: 'login', sign_out: 'logout' }

      get '/home', to: 'home#index', as: 'home'

      get 'help', to: 'pages#help', defaults: { format: :html }, constraints: { format: :html }
      get 'manual', to: 'pages#manual', defaults: { format: :html }
      get 'changelog', to: 'pages#changelog', defaults: { format: :html }, constraints: { format: :html }
      get 'news', to: 'home#news', defaults: { format: :json }, constraints: { format: :json }, as: :news

      concern :attachable do
        patch :attachment_create, on: :member
        patch :attachment_update
        delete 'attachments/:file_id/delete', on: :member, action: :attachment_destroy, as: :attachment_destroy #, on: :member #, defaults: { format: :js }, constraints: { format: :js }
        get 'attachments/:file_id/download', on: :member, action: :attachment_download, as: :attachment_download
        get :attachments, on: :member
      end

      scope path: '/admin' do
        get :index, to: 'home#admin', as: :admin, defaults: { format: :html }, constraints: { format: :html }
        get :logs, to: 'home#logs'
        get :historicizes, to: 'home#historicizes', defaults: { format: :js }, constraints: { format: :js }
        resources :matrix_types, except: [ :show ] do 
          get 'category', on: :collection, to: 'matrix_types#new', new_category: true, as: 'new_category'
        end
        resources :units, except: [ :show ]
        resources :analisy_types, except: [ :show ]
        resources :nuclides, except: [ :show ]
        resources :instructions, except: [ :show ] do
          get :download, on: :member
        end
        resources :users do
          put 'lock', on: :member, to: 'users#lock'
          put 'unlock', on: :member, to: 'users#unlock'
        end
      end

      resources :jobs, concerns: [ :attachable ] do
        get 'show(/:section)', on: :member, to: 'jobs#show', as: :section, section: /details|contacts|design|roles|attachments/
        get 'print', on: :member, to: 'jobs#print'
        get 'analisies', on: :member, to: 'jobs#analisies'
        get 'printed', on: :member, to: 'jobs#printed', defaults: { format: :pdf }, constraints: { format: :pdf }
        get 'search', on: :collection, defaults: { format: :html }, constraints: { format: :html }
        get 'logs', on: :member, to: 'jobs#logs'
        get 'reopen', on: :member, to: 'jobs#reopen', defaults: { format: :html }, constraints: { format: :html }
        post 'reopened', on: :member, to: 'jobs#reopen', defaults: { format: :js }, constraints: { format: :js }
        get 'deleted', on: :collection, to: 'jobs#deleted', defaults: { format: :html }, constraints: { format: :html }
        get 'edit(/:section)', on: :member, to: 'jobs#edit', as: :section_edit, section: /details|contacts|design|roles|attachments/, defaults: { format: :html }
        resources :import, only: :index do
          get :template, on: :collection, to: 'import#template', defaults: { format: :xlsx }, constraints: { format: :xlsx }
          post :verify, on: :collection, to: 'import#verify' #, defaults: { format: :js }, constraints: { format: :js }
          put :create, on: :collection, to: 'import#create', defaults: { format: :js }, constraints: { format: :js }
        end
        resources :timetables do
          get '(/:section)', on: :collection, to: 'timetables#index', section: /table/, as: :section #, defaults: { format: :html }
          get 'template', on: :collection, to: 'timetables#template', template: /standard|radon/, defaults: { format: :html }, constraints: { format: :html }
          get 'print', on: :collection, to: 'timetables#print', defaults: { format: :xlsx }, constraints: { format: :xlsx }
          put 'changeorder', on: :member, to: 'timetables#changeorder', defaults: { format: :js }, constraints: { format: :js }
        end
        resources :samples do
          resources :analisies do
            resources :results, only: :none do
              match 'results', via: [:get, :patch], on: :collection, to: 'analisies#results', defaults: { format: :html }, constraints: { format: :html }
              get 'edit', on: :member, to: 'analisies#result_edit', defaults: { format: :html }, constraints: { format: :html }, as: :edit
            end
          end
        end
        resources :analisies, only: [:index]
        resources :reports, only: [:index, :create, :delete, :destroy] do
          get '(/:section)(/:report_type)', on: :collection, to: 'reports#index', section: /issued|notissued|cancelled/, report_type: /single|multiple/, as: :filtered
          get :download, on: :member, to: 'reports#download', as: :download, defaults: { format: :pdf }, constraints: { format: :pdf }
          get :delete, on: :member, to: 'reports#delete', as: :delete

        end
      end
      get 'notauthorized', :to => redirect('/401.html')
    end

    root 'home#index'
  #end

  # get '/:locale', to: 'home#index'
end
