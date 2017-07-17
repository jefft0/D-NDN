/*
 * Copyright (C) 2017 Regents of the University of California.
 * @author: Jeff Thompson <jefft0@remap.ucla.edu>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 * A copy of the GNU Lesser General Public License is in the file COPYING.
 */

module net.named_data.dndn.util.change_counter;

import net.named_data.dndn.util.change_countable;

/**
 * A ChangeCounter keeps a pointer to a target ChangeCountable whose change
 * count is tracked by a local change count.  You can set to a new target which
 * updates the local change count, and you can call checkChanged
 * to check if the target (or one of the target's targets) has been changed.
 */
class ChangeCounter(T:ChangeCountable) {
  /**
   * Create a new ChangeCounter to track the given target. If target is not null,
   * this sets the local change counter to target.getChangeCount().
   * Params:
   * target = The target to track. This may be null.
   */
  this(T target)
  {
    target_ = target;
    changeCount_ = (target_ is null ? 0 : target_.getChangeCount());
  }

  /**
   * Get the target object.  If the target is changed, then checkChanged will
   * detect it.
   * Returns: The target object.
   */
  final T
  get() { return target_; }

  /**
   * Set the target to the given target.  If target is not null, this sets the
   * local change counter to target.getChangeCount().
   * Params:
   * target = The target to track. This may be null.
   */
  final void
  set(T target) 
  { 
    target_ = target;
    changeCount_ = (target_ is null ? 0 : target_.getChangeCount());
  }

  /**
   * If the target's change count is different than the local change count, then
   * update the local change count and return true.  Otherwise return false,
   * meaning that the target has not changed. Also, if the target is null,
   * simply return false.This is useful since the target (or one of the target's
   * targets) may be changed and you need to find out.
   * Returns: True if the change count has been updated, false if not.
   */
  final bool checkChanged()
  {
    if (target_ is null)
      return false;
    
    ulong targetChangeCount = target_.getChangeCount();
    if (changeCount_ != targetChangeCount) {
      changeCount_ = targetChangeCount;
      return true;
    }
    else
      return false;
  }

  private T target_;
  private ulong changeCount_;
}
