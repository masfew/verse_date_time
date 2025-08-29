
#===========================================================#
#                                                           #
#   ███╗   ███╗ █████╗ ███████╗███████╗███████╗██╗    ██╗   #
#   ████╗ ████║██╔══██╗██╔════╝██╔════╝██╔════╝██║    ██║   #
#   ██╔████╔██║███████║███████╗█████╗  █████╗  ██║ █╗ ██║   #
#   ██║╚██╔╝██║██╔══██║╚════██║██╔══╝  ██╔══╝  ██║███╗██║   #
#   ██║ ╚═╝ ██║██║  ██║███████║██║     ███████╗╚███╔███╔╝   #
#   ╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝╚═╝     ╚══════╝ ╚══╝╚══╝    #
#                                                           #
#                 Created by @MasfewFN on X                 #
#===========================================================#

using { /Verse.org/Simulation }

# Constants
DATETIME_DAY_SECONDS:int = 86400
DATETIME_HOUR_SECONDS:int = 3600
DATETIME_MINUTE_SECONDS:int = 60

#===================================================#
#                                                   #
#                    Date Time                      #=====================================================================================
#                                                   #
#===================================================#

date_time := class<final><concrete>:
    @editable Timezone:time_zone = time_zone.UTC
    @editable Year:int = 0
    @editable Month:int = 0
    @editable Day:int = 0
    @editable Hour:int = 0
    @editable Minute:int = 0
    @editable Second:int = 0

    # Returns a formatted date from the given format
    # MDY => Wednesday, August 13, 2025 | 08/13/2025
    # DMY => Wednesday, 13 August 2025 | 13/08/2025
    # YMD => 2025 August 13, Wendesday | 2025/08/13
    GetDateString(
        ?Format:date_format = date_format.MDY,
        ?ShowMonthAsWord:logic = false,
        ?AbbreviateYear:logic = false,
        ?ShowDayOfWeek:logic = false,
        ?NumericalSeparator:string = "/",
        ?ShowLeadingZeros:logic = true
    ):string=
        CalendarInfo:calendar_info = calendar_info{}
        DateTimeDST := CalculateDST()

        var DateString:string = ""
        YearString := if (AbbreviateYear?, AbbYear := Mod[Year, 100]) then "{AbbYear}" else "{DateTimeDST.Year}"
        DayDigits := GetDigits(DateTimeDST.Day)
        DayString := if (DayDigits(0) > 0 or ShowLeadingZeros?) then "{DayDigits(0)}{DayDigits(1)}" else "{DayDigits(1)}"
        MonthDigits := GetDigits(DateTimeDST.Month)
        NumericalMonthString := if (MonthDigits(0) > 0 or ShowLeadingZeros?) then "{MonthDigits(0)}{MonthDigits(1)}" else "{MonthDigits(1)}"

        case (Format):
            # MDY
            date_format.MDY =>
                if (Format = date_format.MDY):
                    set DateString =
                        if (ShowMonthAsWord?, MonthString := CalendarInfo.Months[DateTimeDST.Month - 1].String):
                            "{MonthString} {DayString}, {YearString}"
                        else { "{NumericalMonthString}{NumericalSeparator}{DayString}{NumericalSeparator}{YearString}" }
                    if (ShowDayOfWeek?) { set DateString = "{CalendarInfo.GetDayOfWeekString(DateTimeDST)}, " + DateString }
            # DMY
            date_format.DMY =>
                set DateString =
                    if (ShowMonthAsWord?, MonthString := CalendarInfo.Months[DateTimeDST.Month - 1].String):
                        "{DayString} {MonthString} {YearString}"
                    else { "{DayString}{NumericalSeparator}{NumericalMonthString}{NumericalSeparator}{YearString}" }
                if (ShowDayOfWeek?) { set DateString = "{CalendarInfo.GetDayOfWeekString(DateTimeDST)}, " + DateString }
            # YMD
            date_format.YMD =>
                set DateString =
                    if (ShowMonthAsWord?, MonthString := CalendarInfo.Months[DateTimeDST.Month - 1].String):
                        "{YearString} {MonthString} {DayString}"
                    else { "{YearString}{NumericalSeparator}{NumericalMonthString}{NumericalSeparator}{DayString}" }
                if (ShowDayOfWeek?) { set DateString += ", {CalendarInfo.GetDayOfWeekString(DateTimeDST)}" }

        return DateString

    # Returns a string of Hour:Minute:Second
    # Optional 12-hour AM/PM or 24-hour formats
    GetTimeString(
        ?UseMilitaryTime:logic = false,
        ?ShowLeadingZeros:logic = false,
        ?ShowTimezone:logic = true,
        ?Separator:string = ":"
    ):string=
        DateTimeDST := CalculateDST()
        SecondsDigits := GetDigits(DateTimeDST.Second)
        MinutesDigits := GetDigits(DateTimeDST.Minute)
        var TimeString:string = "{MinutesDigits(0)}{MinutesDigits(1)}{Separator}{SecondsDigits(0)}{SecondsDigits(1)}"

        if (UseMilitaryTime?):
            HoursDigits := GetDigits(DateTimeDST.Hour)
            set TimeString = "{HoursDigits(1)}{Separator}" + TimeString
            if (HoursDigits(0) > 0 or ShowLeadingZeros?) { set TimeString = "{HoursDigits(0)}" + TimeString }
        else:
            var Suffix:string = ""
            HoursDigits :=
                if (DateTimeDST.Hour < 12):
                    set Suffix = "AM"
                    if (DateTimeDST.Hour > 0) then GetDigits(DateTimeDST.Hour) else (1, 2)
                else:
                    DateTimePM := DateTimeDST.AddHours(-12)
                    set Suffix = "PM"
                    if (DateTimePM.Hour > 0) then GetDigits(DateTimePM.Hour) else (1, 2)
            set TimeString = "{HoursDigits(1)}{Separator}" + TimeString
            if (HoursDigits(0) > 0 or ShowLeadingZeros?) { set TimeString = "{HoursDigits(0)}" + TimeString }
            set TimeString += " {Suffix}"

        if (ShowTimezone?) { set TimeString += " {GetTimezoneString(DateTimeDST.Timezone)}" }
        return TimeString

    # Returns a string treating the DateTime as a duration of time (ex. DD HH:MM:SS)
    GetDurationString(
        ?ShowLeadingZeros:logic = true,
        ?AlwaysShowDays:logic = true,
        ?AlwaysShowHours:logic = true,
        ?AlwaysShowMinutes:logic = true,
        ?DaySeparator:string = ":",
        ?TimeSeparator:string = ":"
    ):string=
        var DurationString:string = ""

        SecondsDigits := GetDigits(Second)
        set DurationString = "{SecondsDigits(1)}"
        if (SecondsDigits(0) > 0) { set DurationString = "{SecondsDigits(0)}" + DurationString }
        else if (AlwaysShowMinutes? or AlwaysShowHours? or AlwaysShowDays? or Minute > 0 or Hour > 0 or Day > 0 or ShowLeadingZeros?):
            set DurationString = "0" + DurationString

        MinutesDigits := GetDigits(Minute)
        if (Minute > 0):
            set DurationString = "{MinutesDigits(1)}{TimeSeparator}" + DurationString
            if (MinutesDigits(0) > 0 or AlwaysShowHours? or AlwaysShowDays? or Hour > 0 or Day > 0):
                set DurationString = "{MinutesDigits(0)}" + DurationString
            else if (ShowLeadingZeros?):
                set DurationString = "0" + DurationString
        else:
            if (AlwaysShowHours? or AlwaysShowDays? or Hour > 0 or Day > 0):
                set DurationString = "00{TimeSeparator}" + DurationString
            else if (AlwaysShowMinutes?):
                set DurationString = "0{TimeSeparator}" + DurationString
                if (ShowLeadingZeros?) { set DurationString = "0" + DurationString }
                return DurationString

        HoursDigits := GetDigits(Hour)
        if (Hour > 0):
            set DurationString = "{HoursDigits(1)}{TimeSeparator}" + DurationString
            if (HoursDigits(0) > 0 or AlwaysShowDays? or Day > 0):
                set DurationString = "{HoursDigits(0)}" + DurationString
            else if (ShowLeadingZeros?):
                set DurationString = "0" + DurationString
        else:
            if (AlwaysShowDays? or Day > 0):
                set DurationString = "00{TimeSeparator}" + DurationString
            else if (AlwaysShowHours?):
                set DurationString = "0{TimeSeparator}" + DurationString
                if (ShowLeadingZeros?) { set DurationString = "0" + DurationString }
                return DurationString

        DaysDigits := GetDigits(Day)
        if (Day > 0) { set DurationString = "{Day}{DaySeparator}" + DurationString }
        else if (AlwaysShowDays?) { set DurationString = "0{DaySeparator}" + DurationString }

        return DurationString

    # Basic time/date format (primarily made for debugging)
    # HH:MM:SS, DOW, MM/DD/YYYY
    GetBasicString()<transacts>:string=
        DateTimeDST := CalculateDST()
        MinuteString := if (DateTimeDST.Minute < 10) then "0{DateTimeDST.Minute}" else "{DateTimeDST.Minute}"
        SecondString := if (DateTimeDST.Second < 10) then "0{DateTimeDST.Second}" else "{DateTimeDST.Second}"
        MDY := "{DateTimeDST.Month}/{DateTimeDST.Day}/{DateTimeDST.Year}"
        HMS := "{DateTimeDST.Hour}:{MinuteString}:{SecondString}"
        DOW := "{calendar_info{}.GetDayOfWeekString(DateTimeDST)}"
        return "{HMS}, {DOW}, {MDY} {GetTimezoneString(DateTimeDST.Timezone)}"

    GetTimezoneString()<transacts>:string = { GetTimezoneString(Timezone) }

    GetTimezoneString(InTimezone:time_zone)<transacts>:string=
        case (InTimezone):
            time_zone.UTC => "UTC"
            time_zone.EST => "EST"
            time_zone.CST => "CST"
            time_zone.MST => "MST"
            time_zone.PST => "PST"

    #==========================================

    # Returns Seconds (tens, ones). Accounts for daylight savings
    GetSecondDigits():tuple(int, int) = { GetDigits(CalculateDST().Second) }

    # Returns Minutes (tens, ones). Accounts for daylight savings
    GetMinuteDigits():tuple(int, int) = { GetDigits(CalculateDST().Minute) }

    # Returns Hours (tens, ones). Accounts for daylight savings
    GetHourDigits():tuple(int, int) = { GetDigits(CalculateDST().Hour) }

    # Returns Days (tens, ones). Accounts for daylight savings
    GetDayDigits():tuple(int, int) = { GetDigits(CalculateDST().Day) }

    # Returns digits of input (tens, ones)
    GetDigits<private>(Input:int):tuple(int, int)=
        if (Input < 10) { return (0, Input) }
        else if:
            Tens := Quotient[Input, 10]
            Ones := Mod[Input, 10]
        then:
            return (Tens, Ones)
        else:
            return (0, 0)

    # Calculate daylight savings offset
    CalculateDST()<transacts>:date_time=
        TimezoneInfo:time_zone_info = time_zone_info{}
        if (TimezoneInfo.Timezones[Timezone].ObservesDST?):
            for:
                DSTInfo : TimezoneInfo.DSTInfo[Year]
                DSTInfo.Timezones.Find[Timezone]
                Self.IsGreaterThanOrEqualTo[DSTInfo.Start] and Self.IsLessThan[DSTInfo.End]
            do:
                return Self.AddHours(1).MatchTimezone(Self)
        return Self

#===================================================#
#                                                   #
#                 Basic Functions                   #=====================================================================================
#                                                   #
#===================================================#

# Constructor
UpdateDateTime<constructor>(Source:date_time)<transacts> := date_time:
    Timezone := Source.Timezone
    Year := Source.Year
    Month := Source.Month
    Day := Source.Day
    Hour := Source.Hour
    Minute := Source.Minute
    Second := Source.Second

#=====================================================================================

# Gets the current DateTime
GetCurrentDateTime()<transacts>:date_time=
    if (DateTime := GetDateTimeFromSecondsSinceEpoch[GetSecondsSinceEpoch()]) { return DateTime }
    else:
        Print("ERROR: Failed to get the current DateTime")
        return date_time{}

# Calculates DateTime from SecondsSinceEpoch
# ?TimezoneOffset used in SetTimezone() function
GetDateTimeFromSecondsSinceEpoch(SecondsSinceEpoch:float, ?TimezoneOffset:int = 0)<transacts><decides>:date_time=
    CalendarInfo:calendar_info = calendar_info{}
    OffsetSeconds := TimezoneOffset * DATETIME_HOUR_SECONDS * 1.0
    SecondsSinceEpochInt := Int[SecondsSinceEpoch + OffsetSeconds]

    # Year
    var Year:int = 1970
    var CountedSeconds:int = 0
    loop:
        CurrentYearSeconds := DATETIME_DAY_SECONDS * GetDaysInYear(Year)
        if (CountedSeconds > SecondsSinceEpochInt - CurrentYearSeconds) { break }
        else:
            set Year += 1
            set CountedSeconds += CurrentYearSeconds

    # Month
    var Month:int = 1
    loop:
        if:
            MonthInfo := CalendarInfo.Months[Month - 1]
            CurrentMonthSeconds := DATETIME_DAY_SECONDS * (MonthInfo.Days + if (IsLeapYear[Year]) then MonthInfo.LeapDays else 0)
        then:
            if (CountedSeconds > SecondsSinceEpochInt - CurrentMonthSeconds) { break }
            else:
                set Month += 1
                set CountedSeconds += CurrentMonthSeconds
        else:
            break

    # DHMS
    Day := Quotient[SecondsSinceEpochInt - CountedSeconds, DATETIME_DAY_SECONDS] + 1
    set CountedSeconds += (Day - 1) * DATETIME_DAY_SECONDS

    Hour := Quotient[SecondsSinceEpochInt - CountedSeconds, DATETIME_HOUR_SECONDS]
    set CountedSeconds += Hour * DATETIME_HOUR_SECONDS

    Minute := Quotient[SecondsSinceEpochInt - CountedSeconds, DATETIME_MINUTE_SECONDS]
    Second := SecondsSinceEpochInt - CountedSeconds - (Minute * DATETIME_MINUTE_SECONDS)

    return date_time:
        Timezone := time_zone.UTC
        Year := Year
        Month := Month
        Day := Day
        Hour := Hour
        Minute := Minute
        Second := Second

#==========================================

# Calculates SecondsSinceEpoch from DateTime
# Defaults to UTC (actual SecondsSinceEpoch), but can be manually overriden to keep the Timezone offset
CalculateSecondsSinceEpoch(DateTime:date_time, ?KeepTimezoneOffset:logic = false)<transacts>:float=
    CalendarInfo:calendar_info = calendar_info{}
    TimezoneInfo:time_zone_info = time_zone_info{}
    var SecondsSinceEpoch:int = 0
    set SecondsSinceEpoch += DateTime.Second
    set SecondsSinceEpoch += DateTime.Minute * DATETIME_MINUTE_SECONDS
    set SecondsSinceEpoch +=
        if (KeepTimezoneOffset?) { DateTime.Hour * DATETIME_HOUR_SECONDS }
        else { (DateTime.Hour - TimezoneInfo.GetOffset(DateTime.Timezone)) * DATETIME_HOUR_SECONDS }
    set SecondsSinceEpoch += (DateTime.Day - 1) * DATETIME_DAY_SECONDS

    var Month:int = DateTime.Month - 1
    loop:
        if (MonthDays := CalendarInfo.GetDaysInMonth[Month, DateTime.Year]):
            set SecondsSinceEpoch += MonthDays * DATETIME_DAY_SECONDS
            set Month -= 1
        else:
            break

    var Year:int = DateTime.Year - 1
    loop:
        if (Year < 1970) { break }
        set SecondsSinceEpoch += GetDaysInYear(Year) * DATETIME_DAY_SECONDS
        set Year -= 1

    return SecondsSinceEpoch * 1.0

#===================================================#
#                                                   #
#                  Calendar Info                    #=====================================================================================
#                                                   #
#===================================================#

calendar_info := class<final>:
    # Months
    Months:[]month_info = array: 
        January:month_info =    month_info{Number := 1,  String := "January",   Days := 31}
        February:month_info =   month_info{Number := 2,  String := "February",  Days := 28, LeapDays := 1}
        March:month_info =      month_info{Number := 3,  String := "March",     Days := 31}
        April:month_info =      month_info{Number := 4,  String := "April",     Days := 30}
        May:month_info =        month_info{Number := 5,  String := "May",       Days := 31}
        June:month_info =       month_info{Number := 6,  String := "June",      Days := 30}
        July:month_info =       month_info{Number := 7,  String := "July",      Days := 31}
        August:month_info =     month_info{Number := 8,  String := "August",    Days := 31}
        September:month_info =  month_info{Number := 9,  String := "September", Days := 30}
        October:month_info =    month_info{Number := 10, String := "October",  Days := 31}
        November:month_info =   month_info{Number := 11, String := "November",  Days := 30}
        December:month_info =   month_info{Number := 12, String := "December",  Days := 31}

    DaysOfWeek:[]string = array{"Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"}

    # Returns number of days in a month, accounting for leap years
    GetDaysInMonth(Month:int, Year:int)<transacts><decides>:int=
        MonthInfo := Months[Month - 1]
        return MonthInfo.Days + if (IsLeapYear[Year]) then MonthInfo.LeapDays else 0

    # Returns the DayOfWeek string for the given DateTime (Timezone specific)
    GetDayOfWeekString(DateTime:date_time)<transacts>:string=
        if:
            DaysSinceEpoch := Floor[CalculateSecondsSinceEpoch(DateTime, ?KeepTimezoneOffset := true) / (DATETIME_DAY_SECONDS * 1.0)]
            DayOfWeekString := DaysOfWeek[Mod[(DaysSinceEpoch + 3), 7]]
        then:
            return DayOfWeekString
        Print("ERROR: Failed to find the day of week for DateTime: {DateTime.GetBasicString()}")
        return ""

month_info := struct:
    Number:int
    String:string
    Days:int
    LeapDays:int = 0

date_format := enum:
    MDY
    DMY
    YMD

#==========================================

GetDaysInYear(Year:int)<transacts>:int = { if (IsLeapYear[Year]) then 366 else 365 }

IsLeapYear(Year:int)<transacts><decides>:void=
    Mod[Year, 4] = 0
    not Mod[Year, 100] = 0 or Mod[Year, 400] = 0

#===================================================#
#                                                   #
#                 Time Zone Info                    #=====================================================================================
#                                                   #
#===================================================#

time_zone := enum:
    UTC
    EST
    CST
    MST
    PST

time_zone_object := struct:
    Timezone:time_zone
    ObservesDST:logic
    Offset:int

dst_info := struct:
    Timezones:[]time_zone
    Start:date_time
    End:date_time

time_zone_info := class<final>:

    Timezones:[time_zone]time_zone_object = map:
        time_zone.UTC => time_zone_object{Timezone := time_zone.UTC, ObservesDST := false, Offset := 0}
        time_zone.EST => time_zone_object{Timezone := time_zone.EST, ObservesDST := true,  Offset := -5}
        time_zone.CST => time_zone_object{Timezone := time_zone.CST, ObservesDST := true,  Offset := -6}
        time_zone.MST => time_zone_object{Timezone := time_zone.CST, ObservesDST := true,  Offset := -7}
        time_zone.PST => time_zone_object{Timezone := time_zone.PST, ObservesDST := true,  Offset := -8}

    # Daylight savings info
    DSTInfo:[int][]dst_info = map:
        2024 => array{
            dst_info{
                Timezones := array{time_zone.EST, time_zone.CST, time_zone.MST, time_zone.PST}
                Start := date_time{Year := 2024, Month := 3, Day := 10, Hour := 2}
                End := date_time{Year := 2024, Month := 11, Day := 3, Hour := 2}
            }
        }
        2025 => array{
            dst_info{
                Timezones := array{time_zone.EST, time_zone.CST, time_zone.MST, time_zone.PST}
                Start := date_time{Year := 2025, Month := 3, Day := 9, Hour := 2}
                End := date_time{Year := 2025, Month := 11, Day := 2, Hour := 2}
            }
        }
        2026 => array{
            dst_info{
                Timezones := array{time_zone.EST, time_zone.CST, time_zone.MST, time_zone.PST}
                Start := date_time{Year := 2026, Month := 3, Day := 8, Hour := 2}
                End := date_time{Year := 2026, Month := 11, Day := 1, Hour := 2}
            }
        }
        2027 => array{
            dst_info{
                Timezones := array{time_zone.EST, time_zone.CST, time_zone.MST, time_zone.PST}
                Start := date_time{Year := 2027, Month := 3, Day := 14, Hour := 2}
                End := date_time{Year := 2027, Month := 11, Day := 7, Hour := 2}
            }
        }
        2028 => array{
            dst_info{
                Timezones := array{time_zone.EST, time_zone.CST, time_zone.MST, time_zone.PST}
                Start := date_time{Year := 2028, Month := 3, Day := 12, Hour := 2}
                End := date_time{Year := 2028, Month := 11, Day := 5, Hour := 2}
            }
        }

    # Returns offset from UTC for the given Timezone
    GetOffset(Timezone:time_zone)<transacts>:int=
        if (Offset := Timezones[Timezone].Offset) { return Offset }
        else { return 0 }

# Converts DateTime to the target Timezone
(DateTime:date_time).SetTimezone(InTimezone:time_zone)<transacts>:date_time=
    if:
        NewDateTime :=
            GetDateTimeFromSecondsSinceEpoch[CalculateSecondsSinceEpoch(DateTime), ?TimezoneOffset := time_zone_info{}.GetOffset(InTimezone)]
    then:
        return date_time:
            UpdateDateTime<constructor>(NewDateTime)
            Timezone := InTimezone
    else:
        Print("ERROR: Failed to set timezone for DateTime: {DateTime.GetBasicString()}")
        return DateTime

# Shorthand for converting DateTime to UTC time zone
(DateTime:date_time).ToUTC()<transacts>:date_time = { DateTime.SetTimezone(time_zone.UTC) }

# Shorthand for converting DateTime to EST time zone
(DateTime:date_time).ToEST()<transacts>:date_time = { DateTime.SetTimezone(time_zone.EST) }

# Shorthand for converting DateTime to CST time zone
(DateTime:date_time).ToCST()<transacts>:date_time = { DateTime.SetTimezone(time_zone.CST) }

# Shorthand for converting DateTime to MST time zone
(DateTime:date_time).ToMST()<transacts>:date_time = { DateTime.SetTimezone(time_zone.MST) }

# Shorthand for converting DateTime to PST time zone
(DateTime:date_time).ToPST()<transacts>:date_time = { DateTime.SetTimezone(time_zone.PST) }

# Shorthand for converting DateTime to the same time zone as InDateTime
(DateTime:date_time).MatchTimezone(InDateTime:date_time)<transacts>:date_time = { DateTime.SetTimezone(InDateTime.Timezone) }

#===================================================#
#                                                   #
#                      Math                         #=====================================================================================
#                                                   #
#===================================================#

# Add or subtract days from DateTime
(DateTime:date_time).AddDays(Amount:int)<transacts>:date_time=
    if (NewDateTime := GetDateTimeFromSecondsSinceEpoch[CalculateSecondsSinceEpoch(DateTime) + Amount * DATETIME_DAY_SECONDS * 1.0]):
         return NewDateTime.MatchTimezone(DateTime)
    else:
        Print("ERROR: Failed to add \{{Amount}\} days to DateTime: {DateTime.GetBasicString()}")
        return DateTime

# Add or subtract hours from DateTime
(DateTime:date_time).AddHours(Amount:int)<transacts>:date_time=
    if (NewDateTime := GetDateTimeFromSecondsSinceEpoch[CalculateSecondsSinceEpoch(DateTime) + Amount * DATETIME_HOUR_SECONDS * 1.0]):
         return NewDateTime.MatchTimezone(DateTime)
    else:
        Print("ERROR: Failed to add \{{Amount}\} hours to DateTime: {DateTime.GetBasicString()}")
        return DateTime

# Add or subtract minutes from DateTime
(DateTime:date_time).AddMinutes(Amount:int)<transacts>:date_time=
    if (NewDateTime := GetDateTimeFromSecondsSinceEpoch[CalculateSecondsSinceEpoch(DateTime) + Amount * DATETIME_MINUTE_SECONDS * 1.0]):
         return NewDateTime.MatchTimezone(DateTime)
    else:
        Print("ERROR: Failed to add \{{Amount}\} minutes to DateTime: {DateTime.GetBasicString()}")
        return DateTime

# Add or subtract seconds from DateTime
(DateTime:date_time).AddSeconds(Amount:int)<transacts>:date_time=
    if (NewDateTime := GetDateTimeFromSecondsSinceEpoch[CalculateSecondsSinceEpoch(DateTime) + Amount * 1.0]):
         return NewDateTime.MatchTimezone(DateTime)
    else:
        Print("ERROR: Failed to add \{{Amount}\} seconds to DateTime: {DateTime.GetBasicString()}")
        return DateTime

#=====================================================================================

#
# Comparisons
#

# Succeeds if DateTime1 = DateTime2
(DateTime1:date_time).IsEqualTo(DateTime2:date_time)<transacts><decides>:void=
    CalculateSecondsSinceEpoch(DateTime1) = CalculateSecondsSinceEpoch(DateTime2)

# Succeeds if DateTime1 > DateTime2
(DateTime1:date_time).IsGreaterThan(DateTime2:date_time)<transacts><decides>:void=
    CalculateSecondsSinceEpoch(DateTime1) > CalculateSecondsSinceEpoch(DateTime2)

# Succeeds if DateTime1 >= DateTime2
(DateTime1:date_time).IsGreaterThanOrEqualTo(DateTime2:date_time)<transacts><decides>:void=
    CalculateSecondsSinceEpoch(DateTime1) >= CalculateSecondsSinceEpoch(DateTime2)

# Succeeds if DateTime1 < DateTime2
(DateTime1:date_time).IsLessThan(DateTime2:date_time)<transacts><decides>:void=
    CalculateSecondsSinceEpoch(DateTime1) < CalculateSecondsSinceEpoch(DateTime2)

# Succeeds if DateTime1 <= DateTime2
(DateTime1:date_time).IsLessThanOrEqualTo(DateTime2:date_time)<transacts><decides>:void=
    CalculateSecondsSinceEpoch(DateTime1) <= CalculateSecondsSinceEpoch(DateTime2)

# Returns the amount of time between DateTime1 and DateTime2
# Always returns a positive time
GetTimeBetween(DateTime1:date_time, DateTime2:date_time)<transacts><decides>:date_time=
    SecondsDifference := Abs(CalculateSecondsSinceEpoch(DateTime2) - CalculateSecondsSinceEpoch(DateTime1))
    DateTime := GetDateTimeFromSecondsSinceEpoch[SecondsDifference]
    if (Int[SecondsDifference] < DATETIME_DAY_SECONDS):
        date_time:
            Year := 0
            Month := 0
            Day := 0
            Hour := DateTime.Hour
            Minute := DateTime.Minute
            Second := DateTime.Second
    else:
        DateTime

#===================================================#
#                                                   #
#              Track Realtime Seconds               #=====================================================================================
#                                                   #
#===================================================#

# Class that sends a ClockTickEvent every second with the current DateTime to the nearest second
# Accounts for execution time drift to ensure no seconds are ever skipped
# NOTE: If you need something accurate to <1 second, this may not work for you
date_time_seconds := class:
    ClockTickEvent:event(date_time) = event(date_time){}

    CountClockTicks()<suspends>:void=
        loop:
            DateTime := GetCurrentDateTime()
            ClockTickEvent.Signal(DateTime)
            if (Mod[Int[CalculateSecondsSinceEpoch(DateTime) * 100], 100] > 50) { Sleep(0.96) }
            else { Sleep(1.0) }
