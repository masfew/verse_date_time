
using { /Fortnite.com/Devices }

date_time_example_device := class(creative_device):

    OnBegin<override>()<suspends>:void=

        # Gets the current DateTime
        DateTime := GetCurrentDateTime()

        # Prints the current Date in UTC
        Print("Current Date: " + DateTime.GetDateString())

        # Prints the current time in UTC
        Print("Current Time: " + DateTime.GetTimeString())

        # Converts DateTime to EST
        DateTimeEST := DateTime.ToEST()

        # Prints the current time in EST (accounting for Daylight Savings)
        Print("Current Time (EST): " + DateTimeEST.GetTimeString())

        # Converts DateTime to the same timezone as another DateTime
        DateTimeEST2 := DateTime.MatchTimezone(DateTimeEST)

        # Gets the current DateTime in EST offset by Daylight Savings (EDT)
        # This is automatically done in any of the DateTime.GetString() functions
        DateTimeEDT := DateTimeEST.CalculateDST()

        # Add/Subtract any amount of Days/Hours/Minutes/Seconds
        DateTimeEST_Plus3Days := DateTimeEST.AddDays(3)
        Print("Current Date/Time (EST) + 3 days: " + DateTimeEST_Plus3Days.GetTimeString() + " " + DateTimeEST_Plus3Days.GetDateString())

        DateTimeEST_Plus50Hours := DateTimeEST.AddHours(50)
        Print("Current Date/Time (EST) + 50 hours: " + DateTimeEST_Plus50Hours.GetTimeString() + " " + DateTimeEST_Plus50Hours.GetDateString())

        DateTimeEST_Minus12Minutes := DateTimeEST.AddMinutes(-12)
        Print("Current Date/Time (EST) - 12 minutes: " + DateTimeEST_Minus12Minutes.GetTimeString() + " " + DateTimeEST_Minus12Minutes.GetDateString())

        DateTimeEST_Plus300Seconds := DateTimeEST.AddSeconds(300)
        Print("Current Date/Time (EST) + 300 seconds: " + DateTimeEST_Plus300Seconds.GetTimeString() + " " + DateTimeEST_Plus300Seconds.GetDateString())

        # Creates a DateTime of exactly 7 days
        # Useful when using DateTime as a duration instead of a date/time, such as countdowns
        DateTimeCountdown := date_time{Day := 7}
        Print("Duration: " + DateTimeCountdown.GetDurationString())

        # Get the digits (tens, ones) for Days/Hours/Minutes/Seconds
        # Useful when using custom countdowns (i.e. set each digit individually in a material)
        DayDigits := DateTimeCountdown.GetDayDigits()
        HourDigits := DateTimeCountdown.GetHourDigits()
        MinuteDigits := DateTimeCountdown.GetMinuteDigits()
        SecondDigits := DateTimeCountdown.GetSecondDigits()

        # Sends an event every second with the current DateTime
        DateTimeSeconds := date_time_seconds{}
        spawn{ DateTimeSeconds.CountClockTicks() }
        loop:
            CurrentDateTime := DateTimeSeconds.ClockTickEvent.Await()
            CurrentDateTimeEST := CurrentDateTime.ToEST()
            Print("Current Date/Time (EST)" + CurrentDateTimeEST.GetTimeString() + " " + CurrentDateTimeEST.GetDateString())
            