tell application "Docker" to activate

  tell current window
    set zoomed to true

    set rp_server to create tab with profile "Repairpal"
    set rp_console to create tab with profile "Repairpal"
    # for running random commands
    set rp_free to create tab with profile "Repairpal"
    set rp_lazygit to create tab with profile "Repairpal"

    # IT
    set it_server to create tab with profile "Internaltools"
    set it_console to create tab with profile "Internaltools"
    # for running random commands
    set it_free to create tab with profile "Internaltools"
    set it_lazygit to create tab with profile "Internaltools"

    # Estimator
    set es_console to create tab with profile "Estimator"
    # for running random commands
    set es_free to create tab with profile "Estimator"
    set es_lazygit to create tab with profile "Estimator"

    tell first session of rp_server
      set name to "server"

      write text "mvim . -c 'set titlestring=Repairpal'"
      write text "foreman start"
      set s2 to split vertically with profile "Repairpal"

      tell s2 to write text "rails s"
    end tell

    tell first session of rp_console
      set name to "rails c"
      write text "rails c"
    end tell

    tell first session of rp_lazygit
      write text "lazygit"
    end tell

    # IT
    tell first session of it_server
      set name to "server"

      write text "mvim . -c 'set titlestring=InternalTools'"
      write text "rails s -p 4000"
    end tell

    tell first session of it_console
      set name to "rails c"
      write text "rails c"
    end tell

    tell first session of it_lazygit
      write text "lazygit"
    end tell

    # Estimator
    tell first session of es_console
      set name to "rails c"
      write text "mvim . -c 'set titlestring=Estimator'"
      write text "rails c"
    end tell

    tell first session of es_lazygit
      write text "lazygit"
    end tell

    # window for tests
    set testing_window to create window with profile "Repairpal"
    tell testing_window
      activate
      tell application "System Events"
        # fullscreen
        key code 36 using {command down}
      end tell

      tell first session of current tab
        set s2 to split vertically with profile "Repairpal"
        tell s2
          set s3 to split horizontally with profile "Repairpal"
          set s4 to split horizontally with profile "Repairpal"
          set s5 to split horizontally with profile "Repairpal"
        end tell
        write text "while true; do; ./rp_guard.sh ; echo 'restarting guard'; sleep 1;done;"

        tell s2 to write text "tail -f log/failed_rspec.log"
        tell s3 to write text "./tail_test_logs_requests.sh"
        tell s4 to write text "./tail_test_log_request_queries.sh"
        tell s5 to write text "./tail_test_logs_all.sh"
      end tell

      set it_tests to create tab with profile "Internaltools"
      tell first session of it_tests
        set name to "IT tests"
        write text "bundle exec guard -c"

        set s2 to split vertically with profile "Internaltools"
        tell s2 to write text "tail -f log/test.log"
      end tell

      set es_tests to create tab with profile "Estimator"
      tell first session of es_tests
        set name to "Estimator tests"
        write text "bundle exec guard -c"

        set s2 to split vertically with profile "Estimator"
        tell s2 to write text "tail -f log/test.log"
      end tell
    end tell

    # Set all mvim to fullscreen
    tell application "System Events" to tell process "MacVim"
      delay 0.3
      set value of attribute "AXFullScreen" of every window to true
      --set value of attribute "AXFullScreen" of window 1 to true
      --set value of attribute "AXFullScreen" of window 2 to true
    end tell
end tell
