# frozen_string_literal: true

Rails.application.routes.draw do
  # frozen_string_literal: true

Rails.application.routes.draw do
  constraints host: Settings.routes.web.url_options.host do
    scope module: :web do
      get '/auth/callback', to: 'sessions#create'
      get '/sign_out', to: 'sessions#destroy'

      scope module: :api do
        namespace :v1 do
          resource :users, only: [] do
            get 'me'
            put 'me/seen_tutorial', to: 'users#seen_tutorial'
          end
          # Removed_Payment
          # namespace :payments do
          #   resources :credit_cards, only: %i[index create]
          #   resource :np_billing_address, only: :show
          #   resource :payment_groups, only: :show do
          #     member do
          #       resource :raksul_credit, controller: 'payment_groups/raksul_credit', only: :show
          #     end
          #   end
          #   resources :validate_np_customer, only: %i[create]
          # end

          namespace :online_design do
            resources :designs, only: :index, param: :design_id do
              member do
                resources :pages, only: [], param: :page_id do
                  member do
                    resource :thumbnail, only: :show
                  end
                end
              end
            end
            resources :pdf_processes, param: :uuid, only: %i[show create]
          end
          namespace :order_projects do
            resources :unseen_non_delivery_list_download, only: :index
          end

          resources :order_projects, param: :full_reference_code, only: %i[show index]
          resources :order_to_do_items, only: %i[index] do
            get :count, on: :collection
          end

          resources :category_purposes, only: :index
          resources :category_groups, only: :index
          resources :categories, only: %i[index show] do
            member do
              resources :mailing_methods, only: :index
              resources :category_sales_list, only: :index
              resources :products, only: :index
            end
          end
          resources :orders, only: :create, param: :reference_code do
            post '/prices', on: :collection, to: 'orders/prices#calculate'
            resources :order_projects, only: [] do
              collection do
                get '', action: :list_by_reference_code
                get 'list_waiting_for_upload'
              end
            end
            member do
              resource :delivery_slip, controller: 'orders/delivery_slips', only: :show, as: :delivery_slip_order
              resource :receipt, controller: 'orders/receipts', only: :show, as: :receipt_order
              resource :bill, controller: 'orders/bills', only: :show, as: :bill_order
            end
          end
          # Removed_payment
          # resources :coupons, only: :create, to: 'coupons#validate'
          resources :order_projects, only: [], param: :full_reference_code do
            member do
              resource :cancel, controller: 'order_projects/cancels', only: :update, as: :cancel_order_project
            end
          end
          # resources :projects, only: %i[index show create update destroy], param: :uuid do
          #   resource :address_list, only: %i[create destroy], controller: 'project_address_lists'
          #   member do
          #     resource :update_name, controller: 'projects/update_name', only: :update
          #     resource :project_products, only: :update do
          #       collection do
          #         resource :confirm_print_data, only: %i[update]
          #       end
          #     end
          #   end
          # end
          resources :user_address_lists, param: :uuid, only: %i[show create] do
            member do
              get :preview
              get :valid_list
              put :remove_error
              resource :download, only: :show, as: :download_user_address_lists, controller: 'user_address_lists/downloads'
            end
            collection do
              post :import, to: 'user_address_lists#import'
            end
          end
          resource :user_address_lists, only: [] do
            resources :corporation, only: [] do
              collection do
                post 'calculate', to: 'user_address_lists#corporation_calculate'
                post 'create', to: 'user_address_lists#corporation_create'
              end
            end
          end
          resources :message_notifications, only: :index
          resources :non_delivery_lists, param: :uuid, only: %i[] do
            member do
              resource :download, controller: 'non_delivery_lists/downloads', only: :show, as: :download_non_delivery_lists
            end
          end
          resources :datacheck_sessions, only: %i[create update], param: :uuid do
            collection do
              get '/app_uuid', to: 'datacheck_sessions#publish_app_uuid'
            end
            member do
              resource :reset, controller: 'datacheck_sessions', action: 'reset', only: :update, as: :reset_datacheck_session
            end
          end
          resource :datacheck_webhook, only: %i[show]
          resource :estimate, only: [] do
            get 'calculate_estimate', on: :collection
          end
          resources :inquiries, only: :create

          resources :integration_apps, param: :app_name, only: :index do
            get 'reports', on: :member
          end

          resources :qr_code_scans, param: :uuid, only: :show

          namespace :corporation do
            resources :regions, only: :index
            resources :prefectures, only: :index
            resources :districts, only: %i[] do
              get 'search', to: 'districts#search', on: :collection
            end
            resources :categories, only: :index
            resources :market_listings, only: :index
            resources :search, controller: :companies, action: :search, only: :create
            resources :keywords, controller: :keywords, action: :search, only: :index
            resources :cart_items, only: %i[index create update destroy], param: :uuid do
              post 'estimate' , to: 'estimate', on: :collection
              get 'count', on: :collection
            end
            resources :order_items, only: %i[index update], param: :full_reference_code do
              member do
                resource :download, only: :show, as: :download_corp_list
              end
            end

            resources :orders, only: %i[], param: :reference_code do
              member do
                get 'receipt', to: 'orders#receipt'
              end
            end
          end

          namespace :raksul_pay do
            namespace :corporation do
              resources :checkout_sessions, only: %i[create]
            end
            namespace :dm do
              resources :checkout_sessions, only: %i[create]
            end
          end
        end
      end

      post '/twirp/*package', to: 'twirp#proxy'
    end
  end
end

end
