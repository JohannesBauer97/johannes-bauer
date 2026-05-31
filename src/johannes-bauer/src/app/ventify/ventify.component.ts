import {ChangeDetectionStrategy, Component} from '@angular/core';

@Component({
  selector: 'app-ventify',
  imports: [],
  templateUrl: './ventify.component.html',
  styleUrl: './ventify.component.css',
  // TODO: This component has been partially migrated to be zoneless-compatible.
  // After testing, this should be updated to ChangeDetectionStrategy.OnPush.
  changeDetection: ChangeDetectionStrategy.Default
})
export class VentifyComponent {

}
