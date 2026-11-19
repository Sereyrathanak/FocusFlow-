import '../model/focus_session.dart';
import '../model/student_task.dart';
import '../model/timer_settings.dart';
import 'task_service.dart';

/// UC-07 Manage Focus Session, UC-08 Take Controlled Break.
/// Multi-entity: links a FocusSession to a StudentTask.
class FocusService {
  final TaskService taskService;
  final TimerSettings settings;
  FocusSession? _activeSession;
  int _nextId = 1;

  FocusService(this.taskService, this.settings);

  FocusSession? get activeSession {
    return _activeSession;
  }

  FocusSession startSession(String taskId, DateTime now) {
    // rule 6
    if (_activeSession != null) {
      throw StateError('Another session is already active');
    }
    StudentTask? task = taskService.findById(taskId);
    if (task == null) {
      throw ArgumentError('Task not found');
    }
    // rules 7, 9
    if (task.isCompleted) {
      throw StateError('Cannot focus on a completed task');
    }

    FocusSession session = FocusSession(
      id: 'session-$_nextId',
      taskId: taskId,
      plannedMinutes: settings.focusMinutes,
      startedAt: now,
    );
    _nextId++;
    task.addSession(session);
    _activeSession = session;
    return session;
  }

  void pauseSession() {
    FocusSession? session = _activeSession;
    if (session == null || session.status != SessionStatus.running) {
      throw StateError('No running session');
    }
    session.pause();
  }

  void resumeSession() {
    FocusSession? session = _activeSession;
    if (session == null || session.status != SessionStatus.paused) {
      throw StateError('No paused session');
    }
    session.resume();
  }

  void tick(int minutes) {
    FocusSession? session = _activeSession;
    if (session == null) {
      throw StateError('No active session');
    }
    // rule 8: FocusSession ignores minutes while paused
    session.addFocusedMinutes(minutes);
  }

  void completeSession(DateTime now, {bool markTaskDone = false}) {
    FocusSession? session = _activeSession;
    if (session == null) {
      throw StateError('No active session');
    }
    session.complete(now);
    if (markTaskDone) {
      taskService.completeTask(session.taskId, now);
    }
    _activeSession = null;
  }

  void stopSession(DateTime now) {
    FocusSession? session = _activeSession;
    if (session == null) {
      throw StateError('No active session');
    }
    // rule 14: keep the minutes already done
    // rule 15: the task is NOT completed
    session.stop(now);
    _activeSession = null;
  }

  int startBreak(int minutes) {
    if (minutes != 5 && minutes != 10 && minutes != 15 && minutes != 30) {
      throw ArgumentError('Break must be 5, 10, 15 or 30 minutes');
    }
    // break time is not added to any session, so it is not focus time
    return minutes;
  }
}
