package main

import (
	"encoding/json"
	"fmt"
	"log"
	"math/rand"
	"net/http"
	"runtime"
	"time"
)

type response struct {
	Time string
	Mem  string
}

func load() {
	a := make([]int64, 1024*1024*32)
	for i := range a {
		a[i] = rand.Int63()
	}
	time.Sleep(time.Second * 4)
	a = nil
	runtime.GC()
	//	debug.FreeOSMemory()
	return
}

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		currentTime := time.Now().Format("3:04PM GMT-07 on Jan 02 2006")
		var m runtime.MemStats
		runtime.ReadMemStats(&m)
		memUsage := fmt.Sprintf("Alloc = %v MB, Sys = %v MB", m.Alloc/1024/1024, m.Sys/1024/1024)
		res, _ := json.Marshal(
			&response{
				Time: currentTime,
				Mem:  memUsage,
			})
		fmt.Fprintf(w, "%s", res)
		fmt.Fprintf(w, "\n%d", runtime.NumGoroutine())
		go load()
	})

	log.Fatal(http.ListenAndServe(":8080", nil))
}
