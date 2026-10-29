
{}
  :about "|Machine-generated snapshot. Do not edit directly — changes will be overwritten. Use `calcit query` to inspect and `calcit edit`/`calcit tree` to modify. Run `calcit docs agents --contract` before mutations; use `--full` for first orientation or changed contract digest. Manual edits must follow format and schema conventions, then run `calcit edit format`."
  :package |app
  :entries $ {} $ :default
    {} (:description |) (:init-fn 'app.main/main!) (:mode :js) (:reload-fn 'app.main/reload!) (:target :browser)
      :feature-policy $ {}
      :modules $ [] |respo.calcit/ |respo-ui.calcit/ |reel.calcit/ |js-ffi/
      :type-slots $ {} $ :dispatch-op |app.schema/DispatchOp
  :files $ {}
    'app.comp.container $ %{} 'FileEntry
      :defs $ {} $ 'comp-container
        %{} 'CodeEntry (:doc |)
          :code $ quote $ defcomp comp-container (reel)
            let
                store $ :store reel
                states $ :states store
                cursor $ match (get states :cursor)
                  (:none) ([])
                  (:some value)
                    if (list? value) value $ raise "|Expected List cursor"
                state $ or (reel-schema/read-field states :data)
                  {} $ :content |
              div
                {} $ :class-name $ str-spaced css/global css/row
                textarea $ {}
                  :value $ reel-schema/read-field state :content
                  :placeholder |Content
                  :class-name $ str-spaced css/expand css/textarea
                  :style $ {} $ :height |320px
                  :on-input $ fn (e d!)
                    hint-fn $ Fn (Map Tag Dynamic)
                      Fn Dynamic & Dynamic $ -> Unit
                      -> Unit
                    d! $ schema/Op :states cursor $ assoc state :content (reel-schema/read-field e :value)
                =< 8 $ {}
                div
                  {} $ :class-name css/expand
                  <> "|This is some content with `code`"
                  =< |8px $ {}
                  button $ {} (:class-name css/button) (:inner-text |Run)
                    :on-click $ fn (e d!)
                      hint-fn $ Fn (Map Tag Dynamic)
                        Fn Dynamic & Dynamic $ -> Unit
                        -> Unit
                      println $ reel-schema/read-field state :content
                when dev? $ comp-typed-reel (>> states :reel) reel $ {}
          :examples $ []
          :schema $ quote $ Fn (reel.typed/State app.schema/Op app.schema/Store) (-> respo.schema/Component)
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.comp.container
          :require (respo-ui.css :as css)
            respo.css :refer $ defstyle
            respo.core :refer $ defcomp defeffect <> >> div button textarea span input
            respo.comp.space :refer $ =<
            reel.comp.reel :refer $ comp-typed-reel
            reel.schema :as reel-schema
            app.config :refer $ dev?
            app.schema :as schema
    'app.config $ %{} 'FileEntry
      :defs $ {}
        'Site $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct Site (:storage-key 'String)
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
          :schema $ quote app.config/Site
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.config
    'app.main $ %{} 'FileEntry
      :defs $ {}
        '*reel $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defref *reel (typed/new-reel schema/store)
          :examples $ []
          :schema $ quote $ Ref (reel.typed/State app.schema/Op app.schema/Store)
        'dispatch! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn dispatch! (op)
            when config/dev? $ js/console.log |Dispatch: op
            reset! *reel $ match (typed/decode-control op)
              (:some action) (typed/apply-control updater @*reel action)
              (:none)
                typed/record-op updater @*reel (schema/decode-op op) (generate-id!)
                  :timestamp $ date-now-snapshot
            , &unit
          :examples $ []
          :schema $ quote $ Fn Enum (-> Unit) (:features :js-ffi)
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
            listen-devtools! |k dispatch!
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
            render! mount-target (comp-container @*reel)
              fn (op)
                hint-fn $ Fn Dynamic $ -> Unit
                if (enum? op) (dispatch! op) (raise "|Expected Markup operation Enum")
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :js-ffi)
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.main
          :require
            respo.core :refer $ render! clear-cache!
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
        'DispatchOp $ %{} 'CodeEntry (:doc "|Respo 入口事件合同，容纳应用和 Reel 控制事件；代表值不发送。")
          :code $ quote $ def DispatchOp (:: :unhandled)
          :examples $ []
          :schema $ quote Enum
        'Op $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defenum Op
            :states
              quote $ List Dynamic
              , 'Dynamic
            :hydrate-storage 'app.schema/Store
          :examples $ []
          :schema $ quote EnumDef
        'Store $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct Store
            :states $ quote $ Map Dynamic Dynamic
          :examples $ []
          :schema $ quote StructDef
        'decode-op $ %{} 'CodeEntry
          :doc "|将 Respo/Reel 传入的单 Enum 规范为应用 Op，检查游标列表与存档载荷；不直接断言 nominal 类型。"
          :code $ quote $ defn decode-op (op)
            match op
              (:states cursor data)
                Op :states
                  decode-map-as cursor $ :: 'List 'Dynamic
                  , data
              (:hydrate-storage data)
                match (decode-store data)
                  (:some stored) (Op :hydrate-storage stored)
                  (:none) (raise "|Invalid saved Markup state")
              _ $ raise "|Unknown Markup operation"
          :examples $ []
          :schema $ quote $ Fn Enum (-> app.schema/Op)
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
                    (:none) (Option :some stored)
                    (:some cursor)
                      if (list? cursor) (Option :some stored) (Option :none)
                (:err message) (Option :none)
          :examples $ []
          :schema $ quote $ Fn Dynamic
            -> $ Option app.schema/Store
        'store $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def store
            Store :states $ {} $ :cursor ([])
          :examples $ []
          :schema $ quote app.schema/Store
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.schema
    'app.updater $ %{} 'FileEntry
      :defs $ {} $ 'updater
        %{} 'CodeEntry (:doc |)
          :code $ quote $ defn updater (store op op-id op-time)
            match op
              (:states cursor s)
                assoc store :states $ decode-map-as
                  update-state-tree (:states store) cursor s
                  :: 'Map 'Dynamic 'Dynamic
              (:hydrate-storage data) data
          :examples $ []
          :schema $ quote $ Fn app.schema/Store app.schema/Op String Number (-> app.schema/Store)
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.updater
          :require $ respo.cursor :refer $ update-state-tree
