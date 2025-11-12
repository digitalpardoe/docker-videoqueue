package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/exec"
	"sync"
	"time"
)

type Video struct {
	URL        string
	Downloaded bool
	Retries    int
}

type AddRequest struct {
	URL string `json:"url"`
}

var (
	videos []Video
	mu     sync.Mutex
)

func main() {
	fmt.Println("Starting videoqueue...")
	fmt.Printf("Running as user %d and group %d.\n", os.Getuid(), os.Getgid())

	go downloadWorker()

	http.HandleFunc("/add", addHandler)

	log.Println("Server starting on :4567")
	if err := http.ListenAndServe(":4567", nil); err != nil {
		log.Fatal(err)
	}
}

func downloadWorker() {
	fmt.Println("Starting download thread...")
	for {
		mu.Lock()
		var video *Video
		for i := range videos {
			if !videos[i].Downloaded {
				video = &videos[i]
				break
			}
		}
		mu.Unlock()

		if video == nil {
			fmt.Println("No videos to download.")
		} else {
			downloadVideo(video)
		}

		time.Sleep(60 * time.Second)
	}
}

func downloadVideo(video *Video) {
	args := []string{
		"-f",
		`bv[height<=1080][vcodec~='^((he|a)vc|h26[45])']+ba[acodec~='^(aac|mp4a)']/bv[height<=1080]+ba/bv+ba`,
		"-o",
		`/downloads/%(uploader)s/%(upload_date)s - %(title)s.%(ext)s`,
		video.URL,
	}

	cmd := exec.Command("yt-dlp", args...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	if err := cmd.Run(); err != nil {
		handleError(video)
		return
	}

	fmt.Printf("Finished downloading %s.\n", video.URL)
	mu.Lock()
	video.Downloaded = true
	mu.Unlock()
}

func handleError(video *Video) {
	fmt.Printf("Error downloading %s!\n", video.URL)
	mu.Lock()
	video.Retries++
	if video.Retries >= 3 {
		fmt.Printf("Giving up on %s!\n", video.URL)
		video.Downloaded = true
	}
	mu.Unlock()
}

func addHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	w.Header().Set("Content-Type", "application/json")

	var req AddRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	mu.Lock()
	videos = append(videos, Video{
		URL:        req.URL,
		Downloaded: false,
		Retries:    0,
	})
	mu.Unlock()

	fmt.Printf("Received new video: %s.\n", req.URL)
	w.WriteHeader(http.StatusCreated)
}
