import {ChangeDetectionStrategy, Component} from '@angular/core';
import {faAppStoreIos} from '@fortawesome/free-brands-svg-icons';
import {FontAwesomeModule} from '@fortawesome/angular-fontawesome';

@Component({
  selector: 'app-laundry-symbols',
  templateUrl: './laundry-symbols.component.html',
  styleUrls: ['./laundry-symbols.component.css'],
  imports: [FontAwesomeModule],
  // TODO: This component has been partially migrated to be zoneless-compatible.
  // After testing, this should be updated to ChangeDetectionStrategy.OnPush.
  changeDetection: ChangeDetectionStrategy.Default
})
export class LaundrySymbolsComponent {
  protected readonly faAppStore = faAppStoreIos;
}
