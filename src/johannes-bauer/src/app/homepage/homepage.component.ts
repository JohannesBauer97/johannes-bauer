import {ChangeDetectionStrategy, Component} from '@angular/core';
import {faGithub, faLinkedin, faXing} from '@fortawesome/free-brands-svg-icons';
import {faEnvelope} from '@fortawesome/free-regular-svg-icons';
import {RouterLink} from '@angular/router';
import {FontAwesomeModule} from '@fortawesome/angular-fontawesome';

@Component({
  selector: 'app-homepage',
  templateUrl: './homepage.component.html',
  styleUrls: ['./homepage.component.css'],
  imports: [FontAwesomeModule, RouterLink],
  // TODO: This component has been partially migrated to be zoneless-compatible.
  // After testing, this should be updated to ChangeDetectionStrategy.OnPush.
  changeDetection: ChangeDetectionStrategy.Default
})
export class HomepageComponent {
  protected readonly faGithub = faGithub;
  protected readonly faEnvelope = faEnvelope;
  protected readonly faXing = faXing;
  protected readonly faLinkedIn = faLinkedin;
}
