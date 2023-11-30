(ns day16.core
  (:gen-class)
  (:require clojure.pprint
            clojure.string
            clojure.math.combinatorics))

(def line-pat #"^Valve ([A-Z]{2}) has flow rate=(\d+); tunnels? leads? to valves? ([A-Z]{2}(?:, [A-Z]{2})*)$")

(defn parse-line [line]
  (as-> line it
    (re-matches line-pat it)
    (rest it)
    (zipmap [:valve :flow :tunnels] it)
    (update it :tunnels #(clojure.string/split % #", "))
    (update it :tunnels set)
    (update it :flow #(Integer/parseInt %))))

(defn floyd-warshall [vertices]
  (let
   [dist
    (->> (for [[x {xt :tunnels} _] vertices
               [y {yt :tunnels} _] vertices]
           [[x y] (cond
                    (= x y) 0
                    (contains? xt y) 1
                    (contains? yt x) 1
                    :else Double/POSITIVE_INFINITY)])
         (into {}))

    step
    (fn [m [k i j]]
      (->> (+ (get m [i k]) (get m [k j]))
           (min (get m [i j]))
           (assoc m [i j])))]

   (reduce step dist (for [k (keys vertices)
                           i (keys vertices)
                           j (keys vertices)]
                       [k i j]))))

(defn current-open-flow [flows open-valves]
  (->> open-valves
       (select-keys flows)
       (vals)
       (apply +)))

(defn get-children [flows distances
                    {flow :flow
                     open-valves :open-valves
                     time :time
                     location :location
                     history :history}
                    time-limit]
  (cond
    (= (count flows) (count open-valves))
    ; wait until the time limit
    [{:location location
      :time time-limit
      :open-valves open-valves
      :history history
      :flow (+ flow (* (current-open-flow flows open-valves)
                       (- time-limit time)))}]
    ; if the current location is not open, open it
    (not (contains? open-valves location))
    [{:location location
      :time (inc time)
      :open-valves (conj open-valves location)
      :history (conj history location)
      :flow (+ flow (current-open-flow flows open-valves))}]
    ; otherwise, move to a new location
    :else
    (let [time-left (- time-limit time)]
      (for [new-location (keys flows)
            :let [travel-time (get distances [location new-location])
                  elapsed-time (min time-left travel-time)]
            :when (not (contains? open-valves new-location))]
        {:location new-location
         :time (+ time elapsed-time)
         :open-valves open-valves
         :history history
         :flow (+ flow (* elapsed-time (current-open-flow flows open-valves)))}))))

(defn search [distances flows initial-state time-limit]
  (loop [stack [initial-state]
         best-state {:flow 0}] 
    (cond
      ; if the stack is empty, we're done
      (empty? stack) best-state
      ; if we've hit the time limit, skip this state
      (>= (:time (peek stack)) time-limit)
      (let
       [state (peek stack)
        stack' (pop stack)
        best-state' (if (> (:flow state) (:flow best-state)) state best-state)] 
        (recur stack' best-state'))
      ; open this valve and add its children to the stack
      :else (let [curr (peek stack)
                  stack' (into (pop stack)
                               (get-children distances flows curr time-limit))]
              (recur stack' best-state)))))

(defn -main
  [& args]
  (let [all-valves
        (as-> args it
          (first it)
          (slurp it)
          (clojure.string/split-lines it)
          (map parse-line it)
          (group-by :valve it)
          (update-vals it first))

        positive-valves
        (->> all-valves
             (filter #(> (:flow (second %)) 0))
             (map first)
             (set))

        flows
        (-> all-valves
            (update-vals :flow)
            (select-keys (conj positive-valves "AA")))

        distances (floyd-warshall all-valves)

        initial-state {:location "AA"
                       :time 0
                       :open-valves #{"AA"}
                       :history (clojure.lang.PersistentQueue/EMPTY)
                       :flow 0}

        run (search flows distances initial-state 30)]
    
    (println "Part 1:" (:flow run))
    (clojure.pprint/pprint run)))
