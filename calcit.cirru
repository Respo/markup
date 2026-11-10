
{}
  :about "|Machine-generated snapshot. Do not edit directly — changes will be overwritten. Use `calcit query` to inspect and `calcit edit`/`calcit tree` to modify. Run `calcit docs agents --contract` before mutations; use `--full` for first orientation or changed contract digest. Manual edits must follow format and schema conventions, then run `calcit edit format`."
  :package |app
  :entries $ {} $ :default
    {} (:description |) (:init-fn 'app.main/main!) (:mode :js) (:reload-fn 'app.main/reload!) (:target :browser)
      :feature-policy $ {}
      :modules $ [] |respo.calcit/ |respo-ui.calcit/ |reel.calcit/ |js-ffi/
      :type-slots $ {} $ :dispatch-op 'app.schema/Op
  :files $ {}
    'app.comp.container $ %{} 'FileEntry
      :defs $ {} $ 'comp-container
        %{} 'CodeEntry (:doc |)
          :code $ quote $ defcomp comp-container (reel on-control!)
            let
                store $ :store reel
                states $ :states store
                cursor $ match (get states :cursor)
                  (:none) ([])
                  (:some value)
                    match
                      try-decode-map-as value $ List respo.schema/CoordKey
                      (:ok checked) checked
                      (:err _) (raise "|Expected List cursor")
                state $ let
                    raw $ match (get states :data)
                      (:some value)
                        or value $ {} $ :content |
                      (:none)
                        {} $ :content |
                  if (struct? raw) (&struct:to-map raw)
                    decode-map-as raw $ Map Dynamic Dynamic
                content $ get state :content
              div
                {} $ :class-name $ str-spaced css/global css/row
                textarea $ {}
                  :value $ match content
                    (:some value) value
                    (:none) None
                  :placeholder |Content
                  :class-name $ str-spaced css/expand css/textarea
                  :style $ {} $ :height |320px
                  :on-input $ fn (e d!)
                    hint-fn $ Fn respo.schema/RespoEvent
                      Fn app.schema/Op $ -> Unit
                      -> Unit
                    d! $ schema/Op :edit-content cursor state $ event-value e
                space-x 8
                div
                  {} $ :class-name css/expand
                  <> "|This is some content with `code`"
                  space-x |8px
                  button $ {} (:class-name css/button) (:inner-text |Run)
                    :on-click $ fn (e d!)
                      hint-fn $ Fn respo.schema/RespoEvent
                        Fn app.schema/Op $ -> Unit
                        -> Unit
                      match content
                        (:some value) (println value)
                        (:none) (println nil)
                if dev?
                  Some $ comp-typed-reel (>> states :reel) reel ({}) on-control!
                  , None
          :examples $ []
          :schema $ quote $ Fn (reel.typed/State schema/Op schema/Store)
            Fn reel.typed/Control $ -> Unit
            -> respo.schema/Component
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.comp.container
          :require (respo-ui.css :as css)
            respo.css :refer $ defstyle
            respo.core :refer $ defcomp defeffect <> >> div button textarea span input event-value
            respo.comp.space :refer $ space-x
            reel.comp.reel :refer $ comp-typed-reel
            app.config :refer $ dev?
            app.schema :as schema
    'app.config $ %{} 'FileEntry
      :defs $ {}
        'Site $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct Site (:storage-key String)
          :examples $ []
          :schema $ quote StructDef
        'dev? $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def dev?
            = |dev $ .unwrap-or (get-env |mode) |release
          :examples $ []
          :schema $ quote Bool
        'site $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def site (Site :storage-key |workflow)
          :examples $ []
          :schema $ quote Site
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.config
    'app.main $ %{} 'FileEntry
      :defs $ {}
        '*reel $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defref *reel (typed/new-reel schema/store)
          :examples $ []
          :schema $ quote $ Ref (typed/State schema/Op schema/Store)
        'dispatch! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn dispatch! (op)
            when config/dev? $ js/console.log |Dispatch: op
            reset! *reel $ typed/record-op updater @*reel op (generate-id!)
              :timestamp $ date-now-snapshot
            , &unit
          :examples $ []
          :schema $ quote $ Fn schema/Op (-> Unit) (:features :js-ffi)
        'main! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn main! ()
            println "|Running mode:" $ if config/dev? |dev |release
            if config/dev? $ load-console-formatter!
            match
              storage-get $ :storage-key config/site
              (:some raw)
                match
                  schema/decode-store $ parse-cirru-edn raw
                  (:some stored)
                    dispatch! $ schema/Op :hydrate-storage stored
                  (:none)
                    do (hud! |error "|Ignored invalid saved state")
                      raise "|Invalid saved Markup state; original archive retained"
              (:none) &unit
            render-app!
            add-watch! *reel :changes $ fn (reel prev)
              hint-fn $ Fn (reel.typed/State app.schema/Op app.schema/Store) (reel.typed/State app.schema/Op app.schema/Store) (-> Unit)
              render-app!
            listen-devtools! |k on-control!
            set-before-unload! $ fn (event)
              hint-fn $ Fn js-ffi.browser/EventHost $ -> Unit
              persist-storage!
            add-event-listener! |visibilitychange $ fn (event)
              hint-fn $ Fn js-ffi.browser/EventHost $ -> Unit
              match (visibility-state)
                (:hidden) (persist-storage!)
                _ &unit
            set-interval! persist-storage! 60000
            println "|App started."
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :js-ffi)
        'mount-target $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def mount-target
            .unwrap $ query-selector |.app
          :examples $ []
          :schema $ quote respo.dom/DomElement
        'on-control! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn on-control! (control)
            reset! *reel $ typed/apply-control updater @*reel control
            , &unit
          :examples $ []
          :schema $ quote $ Fn typed/Control (-> Unit)
        'persist-storage! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn persist-storage! ()
            println "|Saved at" $ :iso $ date-now-snapshot
            storage-set! (:storage-key config/site)
              format-cirru-edn $ :store @*reel
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :js-ffi)
        'reload! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn reload! ()
            if (nil? build-errors)
              do (remove-watch! *reel :changes) (clear-cache!)
                add-watch! *reel :changes $ fn (reel prev)
                  hint-fn $ Fn (reel.typed/State app.schema/Op app.schema/Store) (reel.typed/State app.schema/Op app.schema/Store) (-> Unit)
                  render-app!
                reset! *reel $ typed/refresh updater @*reel schema/store
                hud! |ok~ |Ok
              hud! |error build-errors
            , &unit
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :js-ffi)
        'render-app! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn render-app! ()
            render-with! mount-target
              fn () $ comp-container @*reel on-control!
              , dispatch!
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :js-ffi)
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.main
          :require
            respo.core :refer $ render-with! clear-cache!
            app.comp.container :refer $ comp-container
            app.updater :refer $ updater
            app.schema :as schema
            reel.util :refer $ listen-devtools!
            app.config :as config
            |./calcit.build-errors.mjs :default build-errors
            |bottom-tip :default hud!
            js-ffi.shared :refer $ date-now-snapshot
            reel.typed :as typed
            js-ffi.browser :refer $ add-event-listener! set-before-unload! set-interval! storage-get storage-set! visibility-state
            respo.ffi.browser :refer $ query-selector
    'app.schema $ %{} 'FileEntry
      :defs $ {}
        'Op $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defenum Op
            :edit-content (List respo.schema/CoordKey) (Map Dynamic Dynamic) String
            :hydrate-storage app.schema/Store
          :examples $ []
          :schema $ quote EnumDef
        'Store $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct Store
            :states $ Map Dynamic Dynamic
          :examples $ []
          :schema $ quote StructDef
        'decode-store $ %{} 'CodeEntry
          :doc "|本地存档/旧存档的开放入口：已有 Store 保留身份，Map 验证后构造成 Store。states 是应用与 Reel 共用的异构 UI 状态树，不伪装成泛型关系。"
          :code $ quote $ defn decode-store (data)
            let
                result $ if (struct? data)
                  struct-match data
                    Store stored $ Result :ok stored
                    _ external $ if
                      = (&struct:get-name external) :Store
                      try-decode-map-as (&struct:to-map external) 'app.schema/Store
                      Result :err "|Expected Markup Store"
                  try-decode-map-as data 'app.schema/Store
              match result
                (:ok stored)
                  match (get stored.:states :cursor)
                    (:none) (Some stored)
                    (:some cursor)
                      match
                        try-decode-map-as cursor $ List respo.schema/CoordKey
                        (:ok _) (Some stored)
                        (:err _) None
                (:err message) None
          :examples $ []
          :schema $ quote $ Fn Dynamic
            -> $ Option Store
        'store $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def store
            Store :states $ {} $ :cursor ([])
          :examples $ []
          :schema $ quote Store
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.schema
    'app.updater $ %{} 'FileEntry
      :defs $ {} $ 'updater
        %{} 'CodeEntry (:doc |)
          :code $ quote $ defn updater (store op op-id op-time)
            match op
              (:edit-content cursor previous content)
                assoc store :states $ decode-map-as
                  update-state-tree (:states store) cursor $ assoc previous :content content
                  Map Dynamic Dynamic
              (:hydrate-storage data) data
          :examples $ []
          :schema $ quote $ Fn app.schema/Store app.schema/Op String Number (-> app.schema/Store)
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.updater
          :require $ respo.cursor :refer $ update-state-tree
