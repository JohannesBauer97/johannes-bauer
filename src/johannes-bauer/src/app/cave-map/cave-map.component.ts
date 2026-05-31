import {ChangeDetectionStrategy, Component} from '@angular/core';

@Component({
  selector: 'app-cave-map',
  imports: [],
  templateUrl: './cave-map.component.html',
  styleUrl: './cave-map.component.css',
  // TODO: This component has been partially migrated to be zoneless-compatible.
  // After testing, this should be updated to ChangeDetectionStrategy.OnPush.
  changeDetection: ChangeDetectionStrategy.Default
})
export class CaveMapComponent {

}
