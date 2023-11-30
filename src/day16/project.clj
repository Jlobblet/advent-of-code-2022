(defproject day16 "1"
  :url "https://github.com/Jlobblet/advent-of-code-2022/"
  :dependencies [[org.clojure/clojure "1.11.1"]
                 [org.clojure/math.combinatorics "0.2.0"]]
  :main ^:skip-aot day16.core
  :target-path "target/%s"
  :profiles {:uberjar {:aot :all
                       :jvm-opts ["-Dclojure.compiler.direct-linking=true"]}})
