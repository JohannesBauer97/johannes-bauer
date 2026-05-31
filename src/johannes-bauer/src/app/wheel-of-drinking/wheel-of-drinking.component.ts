import {ChangeDetectionStrategy, Component} from '@angular/core';
import {faAppStoreIos} from '@fortawesome/free-brands-svg-icons';
import {FontAwesomeModule} from '@fortawesome/angular-fontawesome';

@Component({
  selector: 'app-wheel-of-drinking',
  templateUrl: './wheel-of-drinking.component.html',
  styleUrls: ['./wheel-of-drinking.component.css'],
  imports: [FontAwesomeModule],
  // TODO: This component has been partially migrated to be zoneless-compatible.
  // After testing, this should be updated to ChangeDetectionStrategy.OnPush.
  changeDetection: ChangeDetectionStrategy.Default
})
export class WheelOfDrinkingComponent {
  protected readonly faAppStore = faAppStoreIos;
}
