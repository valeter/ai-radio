package ru.anisimov.airadio.scheduler;

import java.util.List;

/**
 * @author valter
 */
public record Schedule(
        List<ScheduleItem> scheduleItems
) {

}
