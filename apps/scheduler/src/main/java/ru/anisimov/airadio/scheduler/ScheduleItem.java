package ru.anisimov.airadio.scheduler;

import java.time.LocalTime;

/**
 * @author valter
 */
public record ScheduleItem(
        LocalTime time,
        ScheduleItemType type,
        String path
) {

}
